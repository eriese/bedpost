class Encounter::RiskCalculator
	attr_reader :risk_map

	def initialize(encounter)
		@encounter = encounter
		@people = {
			user: encounter.partnership.user_profile,
			partner: encounter.partnership.partner
		}
		@person = :user

		# get resources
		@diagnoses = Diagnosis.as_map
		@possibles = PossibleContact.as_map
		@instruments = Contact::Instrument.as_map
		@risks = Diagnosis::TransmissionRisk.grouped_by(:possible_contact_id)

		# make tracking maps
		@fluid_map = {
			partner: Hash.new do |hsh, key|
				hsh[key] = Encounter::FluidTracker.new(@instruments[key], :partner)
			end,
			user: Hash.new do |hsh, key|
				hsh[key] = Encounter::FluidTracker.new(@instruments[key], :user)
			end
		}
		@risk_map = Hash.new(0)
		@base_risk = 0
	end

	def track(person = nil, force: false)
		return if @diagnoses.nil? ||
			!(force || @encounter.risks.empty?)

		@person = person if person.present?
		@base_risk =
			case @person
			when :user
				@encounter.partnership.risk_mitigator
			when :partner
				@people[:user].risk_mitigator
			end

		@encounter.contacts.each { |c| track_contact(c) }
		@encounter.set_risks @risk_map
		@encounter.set_schedule schedule(force)
	end

	def schedule(force = false)
		@risk_map.each_with_object({}) do |(diag_id, diag_risk), h|
			diag = @diagnoses[diag_id]
			# recommend a test date for low to high risks
			test_date =
				if force || diag_risk > Diagnosis::TransmissionRisk::ROUTINE_TEST_RISK
					@encounter.took_place + diag.best_test.weeks
				else
					# recommend waiting until routine testing for negligible and no risks
					:routine
				end
			h[test_date] ||= []
			h[test_date] << diag.name
		end
	end

	def track_contact(contact)
		@cur_contact = contact
		@cur_possible = @possibles[contact.possible_contact_id]
		@cur_keys = contact_keys
		# get where the fluids are before this contact began
		fluids_present = get_fluids(true)
		contact_risks = @risks[@cur_possible.id]

		unless !contact_risks || (contact.is_self? && contact.subject != @person)
			contact_risks.each do |risk|
				unless risk.applies_to_contact?(
					@people[contact.subject],
					@people[contact.object]
				)
					next
				end

				old_lvl = @risk_map[risk.diagnosis_id]

				diag = @diagnoses[risk.diagnosis_id]
				diag_fluids_present = fluids_present && diag.in_fluids

				lvl = nil
				# if it's user to user-self and there aren't
				# fluids on the barrier or instrument, it's no risk
				if contact.is_self? && !diag_fluids_present
					lvl = Diagnosis::TransmissionRisk::NO_RISK
				# if barriers are effective and a barrier was used and there are no fluids
				# on the barrier or the infection isn't in fluids, it's low risk
				elsif risk.barriers_effective &&
						contact.has_barrier? && !diag_fluids_present
					lvl = Diagnosis::TransmissionRisk::NEGLIGIBLE
				# apply the recorded risk, and bump it if there are fluids
				else
					lvl = risk.risk_to_person(contact, diag_fluids_present, @person)
					# mitigate risk by the base risk of the partnership,
					# but do not go lower than negligible if tracking risk to the user
					lvl -= @base_risk

					min = @person == :user ? Diagnosis::TransmissionRisk::NEGLIGIBLE : Diagnosis::TransmissionRisk::NO_RISK

					lvl = lvl > min ? lvl : min
				end

				contact.set_risk(risk.diagnosis_id, lvl, risk.caveats)
				# apply the max risk
				@risk_map[risk.diagnosis_id] = lvl if lvl > old_lvl
			end
		end

		# get where fluids are after this contact ended
		get_fluids(false)
	end

	def get_fluids(is_before)
		fluids_present = false
		@cur_keys.each do |k|
			person, inst_id_or_alias, is_subject, other_inst = k
			tracker = @fluid_map[person][inst_id_or_alias]
			if is_before
				tracker.track_before(@cur_contact, is_subject)
				fluids_present = (@cur_contact.is_self? || @person == person) &&
					tracker.fluids_present?(@cur_contact)
			else
				tracker.track_after(@cur_contact, other_inst)
			end
		end
		fluids_present
	end

	def contact_keys
		subject_instrument = @instruments[@cur_possible.subject_instrument_id]
		object_instrument = @instruments[@cur_possible.object_instrument_id]
		[
			[@cur_contact.subject, subject_instrument.alias_name, true, object_instrument],
			[@cur_contact.object, object_instrument.alias_name, false, subject_instrument]
		]
	end
end
