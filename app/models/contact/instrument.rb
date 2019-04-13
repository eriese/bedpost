class Contact::Instrument
  include Mongoid::Document

  field :name, type: Symbol
  field :_id, type: Symbol, default: ->{ name }
  field :user_override, type: Symbol
  field :can_clean, type: Boolean, default: true
  field :conditions, type: Hash
  index({name: 1}, {unique: true})

  has_many :as_subject, class_name: 'PossibleContact', inverse_of: :subject_instrument, dependent: :restrict_with_error
  has_many :as_object, class_name: 'PossibleContact', inverse_of: :object_instrument, dependent: :restrict_with_error


  Contact::ContactType::TYPES.each do |k, c|
    continue if respond_to?(c.inst_key) && respond_to?(c.inverse_inst)
    o_where = {contact_type: c}
    s_where = {contact_type: c, self_possible: true}
    self_key = c.inst_key.to_s + "_self"

    if c.inst_key == c.inverse_inst
      define_method(c.inst_key) {(pluck_opposite(true, o_where) + pluck_opposite(false, o_where)).uniq}
      define_method(self_key) {(pluck_opposite(true, s_where) + pluck_opposite(false, s_where)).uniq}
    else
      define_method(c.inst_key) {pluck_opposite(true, o_where)}
      define_method(c.inverse_inst) {pluck_opposite(false, o_where)}

      define_method(self_key) {pluck_opposite(true, s_where)}
      define_method(c.inverse_inst.to_s + "_self") {pluck_opposite(false, s_where)}
    end
  end

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

  def self.as_map
    if Rails.env.production?
      @@as_map ||= HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
    else
      HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
    end
  end

  def self.display_fields
    [:name]
  end

  private
  def pluck_opposite(is_subject, conditions)
    lst = is_subject ? as_subject : as_object
    to_pluck = is_subject ? :object_instrument : :subject_instrument
    lst.where(conditions).pluck(to_pluck)
  end
end
