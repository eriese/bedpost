class PossibleContact < Contact::BaseContact
	include StaticResource

	field :self_possible, type: Boolean, default: false

	index({ contact_type: 1 }, { unique: false })
	has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'

	def self.hashed_for_partnership
		grouped_by(:contact_type, false)
	end

	def self.display_fields
		[:subject_instrument_id, :contact_type, :object_instrument_id]
	end
end
