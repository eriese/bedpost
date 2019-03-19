class Contact::BarrierType
	attr_reader :key, :condition

	def initialize(hsh)
		@key = hsh[:key]
		@condition = hsh[:condition]
	end

	TYPES = Hash[[{
		key: :fresh
	},{
		key: :old
	},{
		key: :clean_partner,
		condition: :partner_instrument_id
	},{
		key: :clean_self,
		condition: :self_instrument_id
	}].map {|r| res = Contact::BarrierType.new(r); [res.key, res]}]
end
