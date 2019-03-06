class Encounter
  include Mongoid::Document

  field :notes, type: String
  field :fluids, type: Boolean
  field :self_risk, type: Integer
  field :took_place, type: Date

  embedded_in :partnership
end
