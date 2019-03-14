class Contact
  include Mongoid::Document
  field :barriers
  field :order
  field :contact_type, type: Contact::ContactType

  embedded_in :encounter
  belongs_to :partner_instrument, class_name: "Contact::Instrument"
  belongs_to :self_instrument, class_name: "Contact::Instrument"

  validate :contact_must_be_possible

  def contact_must_be_possible
  	unless self_instrument.send(contact_type.inst_key).include? partner_instrument
  		errors.add(:contact_type, :invalid, {attribute: :contact_type})
  	end
  end
end
