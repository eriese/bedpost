class Contact::ContactType
	attr_reader :key, :inst_key, :inverse_inst, :t_key, :subject, :object, :subject_key, :object_key

	def initialize(hsh)
		@key = hsh[:key]
		@inst_key = hsh[:inst_key]
		@inverse_inst = hsh[:inverse_inst]
		@t_key = hsh[:t_key]
		@subject = hsh[:subject]
		@object = hsh[:object]
		@subject_key = hsh[:subject_key]
		@object_key = hsh[:object_key]
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

		def active
			@_actives ||= TYPES.select {|k, v| v.is_active }
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

		def uncache
			@_actives = nil
		end
	end


	private
	DEFAULT_OPTS = {
		subject: :self,
		object: :partner,
		subject_key: :self_instrument_id,
		object_key: :partner_instrument_id
	}

	BASES = [{
		key: :penetrated,
		inst_key: :can_penetrate,
		inverse_inst: :can_be_penetrated_by,
		inverse_key: :penetrated_by
	},{
		key: :touched,
		inst_key: :can_touch,
		inverse_inst: :can_touch,
		object: nil,
		subject: nil
	}]

	ADDL_OPTS = [{}, {
		key: :_self,
		object: :self,
		subject: :self,
	}, {
		key: :_partner,
		inst_add: :_self,
		subject: :partner,
		object: :partner
	}]

	TYPES = Hash[BASES.map do |r|
		merge_opts = DEFAULT_OPTS.reverse_merge({t_key: r[:key]}).merge(r)
		ret = []
		ADDL_OPTS.each do |a|
			has_key = a.has_key? :key
			key_opt = {}
			if has_key
				key_s = a[:key].to_s
				inst_s = (a[:inst_add] || key_s).to_s
				convert_key = Proc.new {|k, is_inst| (r[k].to_s + (is_inst ? inst_s : key_s)).intern}
				key_opt = {
					key: convert_key.call(:key, false),
					inst_key: convert_key.call(:inst_key, true),
					inverse_inst: convert_key.call(:inverse_inst, true)
				}
			end
			all_merged = merge_opts.merge(a).merge(key_opt)

			if r.has_key? :inverse_key
				inv_opts = {
					key: has_key ? (r[:inverse_key].to_s + a[:key].to_s).intern : r[:inverse_key],
					inst_key: all_merged[:inverse_inst],
					inverse_inst: all_merged[:inst_key],
					subject_key: all_merged[:object_key],
					object_key: all_merged[:subject_key],
					subject: all_merged[:object],
					object: all_merged[:subject]
				}

				inv_merged = all_merged.merge(inv_opts)
				inv_res = new(inv_merged)
				ret << [inv_res.key, inv_res]
			end

			res = new(all_merged)
			ret << [res.key, res]
		end
		ret
	end.flatten(1)]
end
