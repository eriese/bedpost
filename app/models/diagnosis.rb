class Diagnosis
	include Mongoid::Document
	include StaticResource

	field :name, type: Symbol
	field :_id, type: Symbol, default: ->{ name }
	field :gestation_min, type: Integer
	field :gestation_max, type: Integer
	field :in_fluids, type: Boolean
	field :local, type: Boolean
	field :only_vaginal, type: Boolean, default: false
	field :category, type: Array

	has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'

	def best_test
		@best ||= gestation_min + gestation_max * 0.25
	end

end
