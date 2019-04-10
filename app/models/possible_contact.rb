class PossibleContact < Contact::BaseContact
	field :self_possible, type: Boolean, default: false

	belongs_to :subject_instrument, class_name: "Contact::Instrument", inverse_of: :as_subject
  belongs_to :object_instrument, class_name: "Contact::Instrument", inverse_of: :as_object
	has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'
end
