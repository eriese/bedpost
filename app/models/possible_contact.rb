class PossibleContact < Contact::BaseContact
	field :self_possible, type: Boolean, default: false

	has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'
end
