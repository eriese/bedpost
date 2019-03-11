require 'rails_helper'

class DeAliasFieldsTestModel
	include Mongoid::Document
	include DeAliasFields

	field :f_1, as: :field1
	field :f_2, as: :field2?
	belongs_to :other_model, class_name: "DeAliasFieldsTestModel", optional: true
end

class DeAliasFieldsTestModel2
	include Mongoid::Document
	include DeAliasFields

	field :f_1, as: :field1
	field :f_2, as: :field2?

	dont_strip_booleans
end

RSpec.describe DeAliasFields, type: :module do
	after :all do
		DeAliasFieldsTestModel.delete_all
		DeAliasFieldsTestModel2.delete_all
	end

	context 'instance methods' do
		describe '#as_json' do
			it 'hashes fields with their aliases' do
				obj = DeAliasFieldsTestModel.new
				result = obj.as_json

				expect(result).to include("field1")
				expect(result).to_not include("f_1")
			end

			it 'does not de-alias _id fields' do
				obj = DeAliasFieldsTestModel.new
				result = obj.as_json

				expect(result).to include("_id")
				expect(result).to_not include("id")
				expect(result).to include("other_model_id")
				expect(result).to_not include("other_model")
			end

			it 'strips question marks off by default' do
				obj = DeAliasFieldsTestModel.new
				result = obj.as_json

				expect(result).to include("field2")
				expect(result).to_not include("field2?")
				expect(result).to_not include("f_2")
			end
		end
	end

	context 'class methods' do
		describe '.dont_strip_booleans' do
			it 'turns of the default question mark stripping' do
				obj = DeAliasFieldsTestModel2.new
				result = obj.as_json

				expect(result).to include("field2?")
				expect(result).to_not include("field2")
				expect(result).to_not include("f_2")
			end
		end
	end
end
