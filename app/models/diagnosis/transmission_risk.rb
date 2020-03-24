class Diagnosis::TransmissionRisk
	include Mongoid::Document
	include StaticResource
	include HasStaticRelations

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

	# translation keys to apply when showing this risk
	field :caveats, type: Array

	# conditions for the risk to apply. if the condition is not met, none of the risks in this instance apply
	field :subject_conditions, type: Array
	field :object_conditions, type: Array
	has_static_relation :possible_contact, class_name: 'PossibleContact'
	has_static_relation :diagnosis, class_name: 'Diagnosis'

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

	def applies_to_contact?(subject_person, object_person)
		return false if subject_conditions.present? &&
			subject_conditions.any? { |c| !subject_person.send(c) }

		return false if object_conditions.present? &&
			object_conditions.any? { |c| !object_person.send(c) }

		true
	end
end
