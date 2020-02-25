class Encounter
	include Mongoid::Document

	field :notes, type: String
	field :fluids, type: Boolean, default: false
	field :self_risk, type: Integer, default: 0
	field :took_place, type: DateTime
	field :partnership_id, type: BSON::ObjectId

	embedded_in :user_profile
	belongs_to :partnership, class_name: 'Partnership'
	embeds_many :contacts, class_name: 'EncounterContact', order: :position.asc
	accepts_nested_attributes_for :contacts, allow_destroy: true

	validates :partnership_id, presence: true, foreign_key: {
		query: proc { |value, record| record.user_profile.partnerships.find(value) }
	}

	validates_presence_of :took_place
	validates_length_of :contacts, minimum: 1
	validates :self_risk, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: Diagnosis::TransmissionRisk::NO_RISK, less_than_or_equal_to: Diagnosis::TransmissionRisk::HIGH}

	def risks
		@risks || {}
	end

	def set_risks(risk_map)
		@risks = risk_map
	end

	def schedule
		@schedule || {}
	end

	def set_schedule(schedule)
		@schedule = schedule
	end

	def overall_risk
		risks.values.max || Diagnosis::TransmissionRisk::NO_RISK
	end

	def partnership
		partnership_id && user_profile.partnerships.find(partnership_id)
	end

	def partnership=(new_ship)
		self.partnership_id = new_ship.id
	end

	def self.display_fields
		[:fluids, :self_risk, :notes]
	end
end
