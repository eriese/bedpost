class Contact::Instrument
  include Mongoid::Document

  field :name, type: Symbol
  field :_id, type: Symbol, default: ->{ name }
  field :user_override, type: Symbol
  field :conditions, type: Hash
  index({name: 1}, {unique: true})


  Contact::ContactType::TYPES.each do |k, c|
    next if relations.has_key? c.inst_key
  	has_and_belongs_to_many c.inst_key, class_name: "Contact::Instrument", inverse_of: c.inverse_inst
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
      hsh[:self_name] = i.get_user_name_for(user)
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
end
