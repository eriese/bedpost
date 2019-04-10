class EncounterContact < Contact::BaseContact
  include NormalizeBlankValues
  field :barriers, type: Array, default: []
  field :position, type: Integer, default: -> {encounter.present? ? encounter.contacts.length : 0}
  field :object, type: Symbol, default: :partner
  field :subject, type: Symbol, default: :user

  embedded_in :encounter

  validate :contact_must_be_possible
  # validates_uniqueness_of :position
  validates_presence_of :position, :object, :subject

  def contact_must_be_possible
  	unless subject_instrument.present? && subject_instrument.send(contact_type.inst_key).include?(object_instrument_id)
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

  def self.display_fields
    [:subject_instrument, :contact_type, :object_instrument, :barriers]
  end
end
