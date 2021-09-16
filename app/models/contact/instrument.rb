class Contact::Instrument
	include Mongoid::Document
	include StaticResource

	field :name, type: Symbol
	field :_id, type: Symbol, default: -> { name }
	field :user_override, type: Symbol
	field :can_clean, type: Boolean, default: false
	field :has_fluids, type: Boolean, default: true
	field :conditions, type: Hash
	field :subject_barriers, type: Array
	field :object_barriers, type: Array

	index({ name: 1 }, { unique: true })

	has_many :as_subject, class_name: 'PossibleContact', inverse_of: :subject_instrument, dependent: :restrict_with_error
	has_many :as_object, class_name: 'PossibleContact', inverse_of: :object_instrument, dependent: :restrict_with_error

	has_many :aliases, class_name: 'Contact::Instrument', inverse_of: :alias_of, dependent: :restrict_with_error
	belongs_to :alias_of, class_name: 'Contact::Instrument', inverse_of: :aliases, optional: true

	def get_user_name_for(profile, &t_block)
		if user_override
			profile.send(user_override)
		elsif !block_given?
			I18n.t(name, scope: 'contact.instrument')
		else
			t_block.call(name, scope: 'contact.instrument')
		end
	end

	def alias_name
		alias_of_id || name
	end

	def self.hashed_for_partnership(user, partner)
		Rails.cache.fetch("partnership_#{user.id}-#{user.updated_at}_#{partner.id}-#{partner.updated_at}", namespace: name,
																																																																																																					expires_in: 3.hours) do
			Hash[as_map.values.map do |i|
				hsh = i.serializable_hash
				# (methods: Contact::ContactType.inst_methods)
				hsh[:user_name] = i.get_user_name_for(user)
				hsh[:partner_name] = i.get_user_name_for(partner)
				hsh[:alias_name] = i.alias_name
				[i.id, hsh]
			end]
		end
	end

	def self.display_fields
		[:name]
	end
end
