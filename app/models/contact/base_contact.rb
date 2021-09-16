class Contact::BaseContact
	include Mongoid::Document
	include HasStaticRelations

	field :contact_type, type: Contact::ContactType, default: :penetrated
	has_static_relation :subject_instrument, class_name: 'Contact::Instrument'
	has_static_relation :object_instrument, class_name: 'Contact::Instrument'

	validates_presence_of :subject_instrument, :object_instrument, :contact_type
end
