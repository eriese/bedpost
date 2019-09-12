class Contact::ContactType
	attr_reader :key, :inst_key, :inverse_inst, :t_key, :subject, :object, :subject_key, :object_key

	def initialize(hsh)
		@key = hsh[:key]
		@inst_key = hsh[:inst_key]
		@inverse_inst = hsh[:inverse_inst]
		@t_key = hsh[:t_key] || hsh[:key]
	end

	def mongoize
		@key
	end

	def display
		return I18n.t(@t_key, scope: "contact.contact_type")
	end

	class << self
		def const_missing(name)
			get(name)
		end

		def get(name)
			TYPES[name.to_s.downcase.intern]
		end

		def mongoize(object)
			object.is_a?(Contact::ContactType) ? object.mongoize : object
		end

		def demongoize(object)
			TYPES[object]
		end

		def evolve(object)
			mongoize(object)
		end

		def inst_methods
			@methods ||= TYPES.map { |k, t| [t.inst_key, t.inverse_inst, t.inst_key.to_s + "_self", t.inverse_inst.to_s + "_self"] }.flatten.uniq
		end
	end


	private
	BASES = [{
		key: :penetrated,
		inst_key: :can_penetrate,
		inverse_inst: :can_be_penetrated_by,
		inverse_key: :penetrated_by
	},{
		key: :touched,
		inst_key: :can_touch,
		inverse_inst: :can_touch,
	},{
		key: :sucked,
		inst_key: :can_suck,
		inverse_inst: :can_be_sucked_by,
		inverse_key: :sucked_by
	},{
		key: :fisted,
		inst_key: :can_fist,
		inverse_inst: :can_be_fisted_by
	}]

	TYPES = Hash[BASES.map {|r| [r[:key], new(r)] }]
end
