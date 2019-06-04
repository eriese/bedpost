class Contact::BarrierType
	attr_reader :key, :conditions, :exclude

	def initialize(hsh)
		@key = hsh[:key]
		@conditions = hsh[:conditions]
		@exclude = hsh[:exclude]
		@encounter_conditions = hsh[:encounter_conditions]
	end

	TYPES = Hash[[{
		key: :fresh,
		exclude: [:old, :clean_subject, :clean_object]
	},{
		key: :old,
		exclude: [:fresh, :clean_subject, :clean_object],
		encounter_conditions: [:has_barrier, :index]
	},{
		key: :clean_subject,
		encounter_conditions: [:subject_instrument_id],
		exclude: [:old, :fresh]
	},{
		key: :clean_object,
		encounter_conditions: [:object_instrument_id],
		exclude: [:old, :fresh]
	}].map {|r| res = Contact::BarrierType.new(r); [res.key, res]}]
end
