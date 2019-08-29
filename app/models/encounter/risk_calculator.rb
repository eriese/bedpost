class Encounter::RiskCalculator
	attr_reader :risk_map

  def initialize(encounter, force = false)
  	@encounter = encounter
    @person = :user

  	return unless force || @encounter.risks.nil?

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

  def track(person = nil)
  	return unless @diagnoses.present?
  	@person = person if person.present?
  	@encounter.contacts.each {|c| track_contact(c)}
  	@encounter.set_risks @risk_map
    @encounter.set_schedule schedule
  end

  def schedule
    @risk_map.keys.each_with_object({}) do |(diag_id), h|
      diag = @diagnoses[diag_id]
      test_date = @encounter.took_place + diag.best_test.weeks
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

  	unless (contact.is_self? && contact.subject != @person) || !@risks.has_key?(@cur_possible._id)
	  	@risks[@cur_possible._id].each do |risk|
	  		#we're looking for the highest risk in the encounter, so if the risk is already listed as high, don't bother calculating
	  		old_lvl = @risk_map[risk.diagnosis_id]
	  		# break if old_lvl == Diagnosis::TransmissionRisk::HIGH

	  		diag = @diagnoses[risk.diagnosis_id]
	  		diag_fluids_present = fluids_present && diag.in_fluids

	  		lvl = nil
	  		# if it's user to user-self and there aren't fluids on the barrier or instrument, it's low risk
	  		if contact.is_self? && !diag_fluids_present
	  			lvl = Diagnosis::TransmissionRisk::NO_RISK
  			# if barriers are effective and a barrier was used and there are no fluids on the barrier or the infection isn't in fluids, it's low risk
	  		elsif risk.barriers_effective && contact.has_barrier? && !diag_fluids_present
	  			lvl = Diagnosis::TransmissionRisk::NEGLIGIBLE
	  		# apply the recorded risk, and bump it if there are fluids
	  		else
	  			lvl = risk.risk_to_person(contact, diag_fluids_present)
	  		end

	  		contact.set_risk(risk.diagnosis_id,lvl)
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
  			fluids_present = (@cur_contact.is_self? || @person == person) && tracker.fluids_present?(@cur_contact)
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
