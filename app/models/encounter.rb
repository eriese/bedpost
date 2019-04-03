class Encounter
  include Mongoid::Document

  field :notes, type: String
  field :fluids, type: Boolean, default: false
  field :self_risk, type: Integer, default: 0
  field :took_place, type: Date

  embedded_in :partnership
  embeds_many :contacts, class_name: 'EncounterContact', order: :position.asc
  accepts_nested_attributes_for :contacts, allow_destroy: true

  validates :self_risk, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10}

  def self.display_fields
  	[:took_place, :fluids, :self_risk, :notes, :contacts]
  end
end
