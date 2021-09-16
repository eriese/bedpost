require 'rails_helper'

RSpec.describe Contact::BarrierType, type: :model do
	context 'BarrierArray mongoid' do
		class BarrierArrayTestModel
			include Mongoid::Document
			field :barriers, type: Contact::BarrierType::BarrierArray
		end

		after :each do
			cleanup(@model)
		end

		it 'sets properly with symbols' do
			@model = BarrierArrayTestModel.new(barriers: [:fresh])
			expect(@model.barriers).to eq [:fresh]
		end

		it 'sets properly with strings' do
			@model = BarrierArrayTestModel.new(barriers: ['fresh'])
			expect(@model.barriers).to eq [:fresh]
		end

		it 'saves properly with symbols' do
			@model = BarrierArrayTestModel.create(barriers: [:fresh])
			@model.reload
			expect(@model.barriers).to eq [:fresh]
		end

		it 'saves properly with strings' do
			@model = BarrierArrayTestModel.create(barriers: ['fresh'])
			@model.reload
			expect(@model.barriers).to eq [:fresh]
		end
	end
end
