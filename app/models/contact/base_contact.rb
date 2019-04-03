class Contact::BaseContact
  include Mongoid::Document

  field :contact_type, type: Contact::ContactType, default: :penetrated
  belongs_to :partner_instrument, class_name: "Contact::Instrument"
  belongs_to :self_instrument, class_name: "Contact::Instrument"

  validates_presence_of :partner_instrument, :self_instrument, :contact_type
end
