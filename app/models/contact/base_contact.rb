class Contact::BaseContact
  include Mongoid::Document

  field :contact_type, type: Contact::ContactType, default: :penetrated
  belongs_to :subject_instrument, class_name: "Contact::Instrument", inverse_of: :as_subject
  belongs_to :object_instrument, class_name: "Contact::Instrument", inverse_of: :as_object

  validates_presence_of :subject_instrument, :object_instrument, :contact_type
end
