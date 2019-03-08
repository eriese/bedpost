class Contact::Instrument
  include Mongoid::Document

  CONTACT_TYPES = {
  	can_penetrate: :can_be_penetrated_by,
  	can_be_penetrated_by: :can_penetrate,
  	can_touch: :can_touch
  }

  field :name
  field :user_override, type: Symbol
  field :conditions, type: Hash

  CONTACT_TYPES.each do |key, value|
  	has_and_belongs_to_many key, class_name: "Contact::Instrument", inverse_of: value
  	has_and_belongs_to_many (key.to_s + "_self").intern, class_name: "Contact::Instrument", inverse_of: nil
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
end
