require 'rails_helper'

class StaticResourceTestModel
	include Mongoid::Document
	include StaticResource

	field :f_1
	field :f_2
end

RSpec.describe StaticResource, type: :module do
	def make_models(num_models, f_1: nil, f_2: nil)
		num_models.times { StaticResourceTestModel.create(f_1: f_1, f_2: f_2) }
	end

	def cache_data
		Rails.cache.redis.data
	end

	def in_cache?(cache_name = "list")
		Rails.cache.exist?(cache_name, namespace: StaticResourceTestModel.name)
	end

	after do
		Rails.cache.clear
		allow(StaticResourceTestModel).to receive(:where).and_call_original
		StaticResourceTestModel.destroy_all
	end

	describe '#clear_all_caches' do
		it 'clears all caches for the class when any instance is updated' do
			make_models(3)
			StaticResourceTestModel.list
			StaticResourceTestModel.as_map
			expect(cache_data.size).to be 2

			model = StaticResourceTestModel.first
			expect(model).to receive(:clear_all_caches).and_call_original
			model.update(f_1: "changed")
			expect(cache_data).to be_empty
		end

		it 'clears all caches for the class when any new instance is created' do
			make_models(3)
			StaticResourceTestModel.list
			expect(in_cache?).to be true

			model = StaticResourceTestModel.new
			expect(model).to receive(:clear_all_caches).and_call_original
			model.save
			expect(in_cache?).to be false
		end

		it 'clears all caches for the class when an instance is destroyed' do
			make_models(3)
			StaticResourceTestModel.list
			expect(in_cache?).to be true

			model = StaticResourceTestModel.last
			expect(model).to receive(:clear_all_caches).and_call_original
			model.destroy
			expect(in_cache?).to be false
		end

		it 'only clears its own caches' do
			make_models(3)
			StaticResourceTestModel.list
			Rails.cache.write("other cache", "some string")

			StaticResourceTestModel.first.clear_all_caches
			expect(in_cache?).to be false
			expect(Rails.cache.exist?("other cache")).to be true
		end

		it 'keeps to itself even with similar class names' do
			make_models(3)
			StaticResourceTestModel.list
			other_namespace = StaticResourceTestModel.name + " "
			Rails.cache.write("other", "some string", namespace: other_namespace)

			StaticResourceTestModel.first.clear_all_caches
			expect(in_cache?).to be false
			expect(Rails.cache.exist?("other", namespace: other_namespace)).to be true
		end
	end

	context 'class_methods' do
		describe '#list' do
			it 'get an array of all entries from the class' do
				num_models = 3
				make_models(num_models)
				result = StaticResourceTestModel.list
				expect(result).to be_a(Array)
				expect(result.size).to be num_models
			end

			it 'caches after the first hit' do
				make_models(3)
				expect(StaticResourceTestModel).to receive(:all).once.and_call_original
				StaticResourceTestModel.list
				expect(in_cache?).to be true
				StaticResourceTestModel.list
			end
		end

		describe '#as_map' do
			it 'gets a HashWithIndifferentAccess of all entries with their ids as keys' do
				num_models = 3
				make_models(num_models)
				result = StaticResourceTestModel.as_map
				expect(result).to be_a(HashWithIndifferentAccess)
				expect(result.size).to be num_models
			end

			it 'caches after the first hit' do
				make_models(3)
				expect(StaticResourceTestModel).to receive(:all).once.and_call_original
				StaticResourceTestModel.as_map
				expect(in_cache?("as_map")).to be true
				StaticResourceTestModel.as_map
			end
		end

		describe '#newest' do
			context 'without arguments' do
				it 'calls order and then last' do
					make_models(2)
					order_query = double('OrderQuery', {last: nil})
					allow(StaticResourceTestModel).to receive(:order) {order_query}
					StaticResourceTestModel.newest
					expect(StaticResourceTestModel).to have_received(:order).with(updated_at: :desc)
					expect(order_query).to have_received(:last)
				end

				it 'caches' do
					make_models(1)
					StaticResourceTestModel.newest
					expect(in_cache? 'newest').to be true
				end
			end

			context 'with arguments' do
				it 'calls where, then order, then last' do
					make_models(2)
					order_query = double('OrderQuery', last: nil)
					where_query = double('WhereQuery', order: order_query)

					allow(StaticResourceTestModel).to receive(:where) {where_query}
					StaticResourceTestModel.newest(f_1: nil)
					expect(StaticResourceTestModel).to have_received(:where).with(f_1: nil)
					expect(where_query).to have_received(:order).with(updated_at: :desc)
					expect(order_query).to have_received(:last)
				end

				it 'caches' do
					make_models(1)
					args = {f_1: nil}
					StaticResourceTestModel.newest(**args)
					expect(in_cache? "newest#{args.to_json}").to be true
				end
			end
		end

		describe '#grouped_by' do
			it 'caches by column and instantiation arguments' do
				make_models(2, f_1: "first")
				make_models(3, f_1: "second")
				StaticResourceTestModel.grouped_by(:f_1)
				expect(in_cache?("f_1_true")).to be true
				StaticResourceTestModel.grouped_by(:f_1, false)
				expect(in_cache?("f_1_false")).to be true
			end

			context 'with instantiate = true (default)' do
				it 'returns a hash of arrays of all entries keyed by their values for the given column' do
					num_first = 3
					make_models(num_first, f_1: "first")
					num_second = 4
					make_models(num_second, f_1: "second")

					result = StaticResourceTestModel.grouped_by(:f_1)
					expect(result).to be_a(HashWithIndifferentAccess)
					expect(result.keys.size).to be 2
					expect(result[:first].size).to be num_first
					expect(result["second"].size).to be num_second
					expect(result[:first][0]).to be_a(StaticResourceTestModel)
				end
			end

			context 'with instantiate = false' do
				it 'returns a hash of arrays of all entries keyed by their values for the given column' do
					num_first = 3
					make_models(num_first, f_1: "first")
					num_second = 4
					make_models(num_second, f_1: "second")

					result = StaticResourceTestModel.grouped_by(:f_1, false)
					expect(result).to be_a(HashWithIndifferentAccess)
					expect(result.keys.size).to be 2
					expect(result[:first].size).to be num_first
					expect(result["second"].size).to be num_second
					expect(result[:first][0]).to be_a(Hash)
				end
			end
		end

		describe '#find_cached' do
			it 'finds an entry by its id' do
				model = StaticResourceTestModel.create
				found = StaticResourceTestModel.find_cached(model.id)
				expect(found).to eq model
			end

			it 'caches the found entry' do
				model = StaticResourceTestModel.create
				expect(StaticResourceTestModel).to receive(:find).with(model.id).once
				StaticResourceTestModel.find_cached(model.id)
				StaticResourceTestModel.find_cached(model.id)
				expect(in_cache?("_id:#{model.id}")).to be true
			end

			it 'accepts an optional argument to look for a field other than id' do
				model = StaticResourceTestModel.create(f_1: "other")
				found = StaticResourceTestModel.find_cached(model.f_1, field: :f_1)
				expect(found).to eq model
			end
		end
	end
end
