class Encounter
  include Mongoid::Document

  field :notes, type: String
  field :fluids, type: Boolean
  field :self_risk, type: Integer
  field :took_place, type: Date

  embedded_in :partnership

  validates :self_risk, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10}
end
