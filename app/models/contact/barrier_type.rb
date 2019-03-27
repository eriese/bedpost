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
		exclude: [:old, :clean_partner, :clean_self]
	},{
		key: :old,
		exclude: [:fresh, :clean_partner, :clean_self],
		encounter_conditions: [:has_barrier, :index]
	},{
		key: :clean_partner,
		conditions: [:partner_instrument_id],
		exclude: [:old, :fresh]
	},{
		key: :clean_self,
		conditions: [:self_instrument_id],
		exclude: [:old, :fresh]
	}].map {|r| res = Contact::BarrierType.new(r); [res.key, res]}]
end
