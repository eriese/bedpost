require 'rails_helper'

class StaticRelationTestModel
	include Mongoid::Document
	include HasStaticRelations

	has_static_relation :static_resource_relation
end

class StaticResourceRelation
	include Mongoid::Document
	include StaticResource
end

RSpec.describe HasStaticRelations, type: :module do
	before do
		@rel1 = StaticResourceRelation.create
		@rel2 = StaticResourceRelation.create
	end

	after do
		cleanup @model, @rel1, @rel2
	end

	describe '#has_static_relation' do
		it 'adds a belongs-to relation to the model' do
			relation = StaticRelationTestModel.relations['static_resource_relation']
			expect(relation).to be_a Mongoid::Association::Referenced::BelongsTo
		end
	end

	describe 'getter' do
		it 'uses the given value instead of hitting the database' do
			model = StaticRelationTestModel.new(static_resource_relation: @rel1)
			allow(StaticResourceRelation).to receive(:cached) { nil }
			expect(model.static_resource_relation).to eq @rel1
		end

		it 'looks in the cache map for the value' do
			model = StaticRelationTestModel.new(static_resource_relation_id: @rel1._id)
			allow(StaticResourceRelation).to receive(:as_map).and_call_original
			allow(StaticResourceRelation).to receive(:find) {nil }
			expect(model.static_resource_relation).to eq @rel1
			expect(StaticResourceRelation).to have_received :as_map
		end
	end

	describe 'validation' do
		it 'does not call find when validating the relation' do
			model = StaticRelationTestModel.new(static_resource_relation_id: "invalid")
			allow(StaticResourceRelation).to receive(:find) {StaticResourceRelation.new }
			expect(model.valid?).to be false
		end
	end
end
