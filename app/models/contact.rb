class Contact
  include Mongoid::Document
  field :barriers, type: Array, default: []
  field :contact_type, type: Contact::ContactType, default: :penetrated
  field :position, type: Integer, default: -> {encounter.present? ? encounter.contacts.length : 0}

  embedded_in :encounter
  belongs_to :partner_instrument, class_name: "Contact::Instrument"
  belongs_to :self_instrument, class_name: "Contact::Instrument"

  validate :contact_must_be_possible
  validates_uniqueness_of :position
  validates_presence_of :partner_instrument, :self_instrument, :position

  def contact_must_be_possible
  	unless self_instrument.present? && self_instrument.send(contact_type.inst_key).include?(partner_instrument)
  		errors.add(:contact_type, :invalid, {attribute: :contact_type})
  	end
  end

  def barrier_validations
  end

  def serializable_hash(options=nil)
  	options = options.present? ? options.deep_dup : {}
  	options[:except] ||= []
  	exclude_contact = options[:except].include? :contact_type
  	options[:except] << :contact_type unless exclude_contact
  	hsh = super
  	hsh[:contact_type] = contact_type.key unless exclude_contact
  	hsh
  end
end
