class Contact::Instrument
  include Mongoid::Document

  field :name, type: Symbol
  field :user_override, type: Symbol
  field :conditions, type: Hash
  index({name: 1}, {unique: true})


  Contact::ContactType.all.each do |c|
  	has_and_belongs_to_many c.inst_key, class_name: "Contact::Instrument", inverse_of: c.inverse_inst
  	has_and_belongs_to_many (c.inst_key.to_s + "_self").intern, class_name: "Contact::Instrument", inverse_of: nil
  end

  def get_user_name_for(profile, &t_block)
  	if self.user_override
  		profile.send(self.user_override)
  	elsif !block_given?
  		I18n.t(self.name)
  	else
  		t_block.call(self.name)
  	end
  end

  # TODO something about not showing toys twice
  def show_for_user(profile, contact_type)
  	c_conditions = conditions[:all] || conditions[contact_type] || conditions[contact_type.to_s.sub("_self", "").intern] if conditions
  	c_conditions.each {|c| return false unless profile.send(c)} if c_conditions
  	true
  end

  def self.by_name
    @@by_name ||= HashWithIndifferentAccess[all.map {|i| [i.name, i]}]
  end

  def self.as_map
    @@as_map ||= HashWithIndifferentAccess[all.map {|i| [i.id, i]}]
  end
end
