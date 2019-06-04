class Encounter
  include Mongoid::Document

  field :notes, type: String
  field :fluids, type: Boolean, default: false
  field :self_risk, type: Integer, default: 0
  field :took_place, type: Date

  embedded_in :partnership
  embeds_many :contacts, class_name: 'EncounterContact', order: :position.asc
  accepts_nested_attributes_for :contacts, allow_destroy: true

  validates :self_risk, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: Diagnosis::TransmissionRisk::NO_RISK, less_than_or_equal_to: Diagnosis::TransmissionRisk::HIGH}

  attr_reader :risks

  def set_risks(risk_map)
    @risks = risk_map
  end

  def overall_risk
    @risks.values.max
  end

  def self.display_fields
  	[:fluids, :self_risk, :notes]
  end
end
