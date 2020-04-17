class StiTestResult
	include Mongoid::Document
	include HasStaticRelations

	embedded_in :sti_test
	field :positive, type: Boolean, default: false
	has_static_relation :tested_for, class_name: 'Diagnosis'

	validates :tested_for_id, uniqueness: true
end
