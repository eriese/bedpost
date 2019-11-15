require 'rails_helper'

class NormalizerTestModel
	include Mongoid::Document
	include NormalizeBlankValues

	field :f_1, type: String
	field :f_2, type: Boolean
end

RSpec.describe NormalizeBlankValues, type: :module do
	after :all do
		NormalizerTestModel.destroy_all
	end
	describe '#normalize_blank_values' do
		it 'is called on save' do
			obj = NormalizerTestModel.new(f_1: "a string", f_2: true)
			allow(obj).to receive(:normalize_blank_values)
			obj.save
			expect(obj).to have_received(:normalize_blank_values)
		end

		it 'normalizes empty fields to nil' do
			obj = NormalizerTestModel.new(f_1: "", f_2: true)
			obj.normalize_blank_values
			expect(obj.f_1).to be_nil
		end

		it 'normalizes empty boolean fields to false' do
			obj = NormalizerTestModel.new(f_1: "a string", f_2: "")
			obj.normalize_blank_values
			expect(obj.f_2).to be false

			obj.f_2 = nil
			obj.normalize_blank_values
			expect(obj.f_2).to be false
		end
	end
end
