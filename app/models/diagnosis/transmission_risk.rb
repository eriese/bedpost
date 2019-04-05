class Diagnosis::TransmissionRisk
  include Mongoid::Document
  field :risk_level, type: Integer
  belongs_to :possible_contact
  belongs_to :diagnosis
end
