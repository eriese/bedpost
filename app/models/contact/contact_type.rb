class Contact::ContactType
	attr_reader :key, :inst_key, :inverse_inst

	def initialize(hsh)
		@key = hsh[:key]
		@inst_key = hsh[:inst_key]
		@inverse_inst = hsh[:inverse_inst]
	end

	def mongoize
		@key
	end

	class << self
		def const_missing(name)
			get(name)
		end

		def all
			TYPES.values
		end

		def get(name)
			TYPES[name.to_s.downcase.intern]
		end

		def mongoize(object)
			object.is_a?(Contact::ContactType) ? object.mongoize : object
		end

		def demongoize(object)
			get(object)
		end

		def evolve(object)
			mongoize(object)
		end
	end


	private
	RAW = [{
		key: :penetrated,
		inst_key: :can_penetrate,
		inverse_inst: :can_be_penetrated_by,
	}, {
		key: :penetrated_by,
		inst_key: :can_be_penetrated_by,
		inverse_inst: :can_penetrate
	}, {
		key: :touched,
		inst_key: :can_touch,
		inverse_inst: :can_touch
	}]
	TYPES = Hash[RAW.map {|r| c = new(r); [c.key, c]}]
end
