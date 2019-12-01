require 'rails_helper'

class NormalizerTestModel
	include Mongoid::Document
	include NormalizeBlankValues

	field :f_1, type: String
	field :f_2, type: Boolean
	field :f_3, type: Array
end

class NormalizerEmbeddingModel
	include Mongoid::Document
	include NormalizeBlankValues

	field :f_1
	embeds_many :normalizer_test_models, cascade_callbacks: true
end

RSpec.describe NormalizeBlankValues, type: :module do
	after :all do
		NormalizerEmbeddingModel.destroy_all
		NormalizerTestModel.destroy_all
	end

	describe '#normalize_blank_values' do
		it 'is called on save' do
			obj = NormalizerTestModel.new(f_1: "a string", f_2: true, f_3: [1, 2, 3])
			allow(obj).to receive(:normalize_blank_values)
			obj.save
			expect(obj).to have_received(:normalize_blank_values)
		end

		it 'normalizes empty string fields to nil' do
			obj = NormalizerTestModel.new(f_1: "", f_2: true, f_3: [1, 2, 3])
			obj.normalize_blank_values
			expect(obj.f_1).to be_nil
		end

		it 'normalizes empty boolean fields to false' do
			obj = NormalizerTestModel.new(f_1: "a string", f_2: "", f_3: [1, 2, 3])
			obj.normalize_blank_values
			expect(obj.f_2).to be false

			obj.f_2 = nil
			obj.normalize_blank_values
			expect(obj.f_2).to be false
		end

		it 'normalizes empty array fields to nil' do
			obj = NormalizerTestModel.new(f_1: "a string", f_2: true, f_3: [])
			obj.normalize_blank_values
			expect(obj.f_3).to be_nil
		end

		it 'normalizes nil array fields to nil' do
			obj = NormalizerTestModel.new(f_1: "a string", f_2: true, f_3: nil)
			obj.normalize_blank_values
			expect(obj.f_3).to be_nil
		end

		it 'gracefully handles embedded objects' do
			obj = NormalizerEmbeddingModel.create(f_1: "a string", normalizer_test_models: nil)
			expect {obj.normalize_blank_values}.to_not raise_error
			expect(obj.normalizer_test_models).to eq []
		end
	end
end
