class Diagnosis::TransmissionRisk
	include Mongoid::Document
	include StaticResource

	NO_DATA = -1
	NO_RISK = 0
	NEGLIGIBLE = 1
	LOW = 2
	MODERATE = 3
	HIGH = 4

	ROUTINE_TEST_RISK = LOW

	field :risk_to_subject, type: Integer
	field :risk_to_object, type: Integer
	field :risk_to_self, type: Integer, default: NO_RISK
	field :barriers_effective, type: Boolean, default: true
	belongs_to :possible_contact, class_name: 'PossibleContact'
	belongs_to :diagnosis, class_name: 'Diagnosis'

	def risk_to_person(encounter_contact, bump_risk, person = :user)
		lvl = NO_RISK
		if encounter_contact.subject == person
			lvl = encounter_contact.is_self? ? risk_to_self : risk_to_subject
		elsif encounter_contact.object == person
			lvl = risk_to_object
		end
		# TODO: risk bumping should be more sophisticated
		lvl += 1 if bump_risk && lvl < HIGH
		lvl
	end
end
