class Contact::Instrument
  include Mongoid::Document
  include StaticResource

  field :name, type: Symbol
  field :_id, type: Symbol, default: ->{ name }
  field :user_override, type: Symbol
  field :can_clean, type: Boolean, default: true
  field :has_fluids, type: Boolean, default: true
  field :conditions, type: Hash
  index({name: 1}, {unique: true})

  has_many :as_subject, class_name: 'PossibleContact', inverse_of: :subject_instrument, dependent: :restrict_with_error
  has_many :as_object, class_name: 'PossibleContact', inverse_of: :object_instrument, dependent: :restrict_with_error

  def get_user_name_for(profile, &t_block)
  	if self.user_override
  		profile.send(self.user_override)
  	elsif !block_given?
  		I18n.t(self.name, scope: 'contact.instrument')
  	else
  		t_block.call(self.name, scope: 'contact.instrument')
  	end
  end

  # TODO something about not showing toys twice
  def show_for_user(profile, contact_type, is_inverse=false)
    type_key = is_inverse ? contact_type.inverse_inst : contact_type.inst_key
    return false if send(type_key).empty?
  	c_conditions = conditions[:all] || conditions[type_key] || conditions[type_key.to_s.sub("_self", "").intern] if conditions.any?
  	c_conditions.each {|c| return false unless profile.send(c)} if c_conditions
  	true
  end

  def self.hashed_for_partnership(user, partner)
    Hash[as_map.values.map do |i|
      hsh = i.serializable_hash
      # (methods: Contact::ContactType.inst_methods)
      hsh[:user_name] = i.get_user_name_for(user)
      hsh[:partner_name] = i.get_user_name_for(partner)
      [i.id, hsh]
    end]
  end

  def self.by_name
    @@by_name ||= HashWithIndifferentAccess[all.map {|i| [i.name, i]}]
  end

  def self.display_fields
    [:name]
  end
end
