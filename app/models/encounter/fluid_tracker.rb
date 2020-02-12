class Encounter::FluidTracker
 attr_reader :own_on_barrier, :other_on_barrier, :own_on_instrument, :other_on_instrument

 def initialize(inst, person)
	@own_on_barrier = []
	@own_on_instrument = []
	@other_on_barrier = []
	@other_on_instrument = []
	@inst = inst
	@person = person
 end

 def track_before(contact, is_subject)
	if @inst.can_clean && contact.barriers.include?(is_subject ? :clean_subject : :clean_object)
		@own_on_instrument = []
		@other_on_instrument = []
	elsif contact.barriers.include?(:fresh)
		@other_on_barrier = []
		@own_on_barrier = []
	end
 end

 def track_after(contact, other_inst, is_subject)
	return unless other_inst.has_fluids

	inst_barriers = is_subject ? @inst.subject_barriers : @inst.object_barriers
	return if contact.has_barrier? && inst_barriers.blank?

	lst = get_list(contact, contact.is_self?)
	lst << other_inst.alias_name
 end

 def fluids_present?(contact)
	# TODO account for own anal bacteria in vagina
	lst = get_list(contact, !contact.is_self?)
	lst.any?
 end

 private
 def get_list(contact, self_state)
	if contact.has_barrier?
		return self_state ? @own_on_barrier : @other_on_barrier
	else
		return self_state ? @own_on_instrument : @other_on_instrument
	end
 end
end
