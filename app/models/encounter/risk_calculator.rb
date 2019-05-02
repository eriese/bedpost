class Encounter::RiskCalculator
	attr_reader :risk_map

  def initialize(encounter)
  	@encounter = encounter

  	#get resources
  	@diagnoses = Diagnosis.as_map
  	@possibles = PossibleContact.as_map
  	@instruments = Contact::Instrument.as_map
  	@risks = Diagnosis::TransmissionRisk.grouped_by(:possible_contact_id)

  	#make tracking maps
  	@fluid_map = {
  		partner: Hash.new { |hsh, key| hsh[key] = Encounter::FluidTracker.new(@instruments[key], :partner) },
  		user: Hash.new { |hsh, key| hsh[key] = Encounter::FluidTracker.new(@instruments[key], :user) },
  	}
  	@risk_map = Hash.new(0)
  end

  def track_contact(contact, person = :user)
  	@cur_contact = contact
  	@cur_person = person
  	@cur_possible = @possibles[contact.possible_contact_id]
  	@cur_keys = contact_keys
  	# get where the fluids are before this contact began
  	fluids_present = get_fluids(true)

  	unless contact.is_self? && contact.subject != person
	  	@risks[@cur_possible._id].each do |risk|
	  		#we're looking for the highest risk in the encounter, so if the risk is already listed as high, don't bother calculating
	  		old_lvl = @risk_map[risk.diagnosis_id]
	  		break if old_lvl == Diagnosis::TransmissionRisk::HIGH

	  		diag = @diagnoses[risk.diagnosis_id]
	  		diag_fluids_present = fluids_present && diag.in_fluids

	  		lvl = nil
	  		# if it's user to user-self and there aren't fluids on the barrier or instrument, it's low risk
	  		if contact.is_self? && !diag_fluids_present
	  			lvl = Diagnosis::TransmissionRisk::NONE
  			# if barriers are effective and a barrier was used and there are no fluids on the barrier or the infection isn't in fluids, it's low risk
	  		elsif risk.barriers_effective && contact.has_barrier? && !diag_fluids_present
	  			lvl = Diagnosis::TransmissionRisk::NEGLIGIBLE
	  		# apply the recorded risk, and bump it if there are fluids
	  		else
	  			lvl = risk.risk_to_person(contact, diag_fluids_present)
	  		end

	  		# apply the max risk
	  		@risk_map[risk.diagnosis_id] = lvl if lvl > old_lvl
	  	end
	  end

	  #get where fluids are after this contact ended
	  get_fluids(false)
  end

  def get_fluids(is_before)
  	fluids_present = false
  	@cur_keys.each do |k|
  		person, inst_id, is_subject, other_inst = k
  		tracker = @fluid_map[person][inst_id]
  		if is_before
  			tracker.track_before(@cur_contact, is_subject)
  			fluids_present = true if (@cur_contact.is_self? || @cur_person == person) && tracker.fluids_present?(@cur_contact)
  		else
  			tracker.track_after(@cur_contact, other_inst)
  		end
  	end
  	fluids_present
  end

  def contact_keys
  	[
  		[@cur_contact.subject, @cur_possible.subject_instrument_id, true, @instruments[@cur_possible.object_instrument_id]],
  		[@cur_contact.object, @cur_possible.object_instrument_id, false, @instruments[@cur_possible.subject_instrument_id]]
  	]
  end
end
