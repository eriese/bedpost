class PossibleContact < Contact::BaseContact
	include StaticResource

	field :self_possible, type: Boolean, default: false

	belongs_to :subject_instrument, class_name: "Contact::Instrument", inverse_of: :as_subject
  belongs_to :object_instrument, class_name: "Contact::Instrument", inverse_of: :as_object

  index({contact_type: 1}, {unique: false})
	has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'

	def self.hashed_for_partnership
		grouped_by(:contact_type)
	end
end
