class Encounter
  include Mongoid::Document

  field :notes, type: String
  field :fluids, type: Boolean, default: false
  field :self_risk, type: Integer, default: 0
  field :took_place, type: Date

  embedded_in :partnership
  embeds_many :contacts, class_name: 'EncounterContact', order: :position.asc
  accepts_nested_attributes_for :contacts, allow_destroy: true


  validates_presence_of :took_place
  validates_length_of :contacts, minimum: 1
  validates :self_risk, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: Diagnosis::TransmissionRisk::NO_RISK, less_than_or_equal_to: Diagnosis::TransmissionRisk::HIGH}

  attr_reader :risks, :schedule

  def set_risks(risk_map)
    @risks = risk_map
  end

  def set_schedule(schedule)
    @schedule = schedule
  end

  def overall_risk
    @risks.values.max || Diagnosis::TransmissionRisk::NO_RISK
  end

  def self.display_fields
  	[:fluids, :self_risk, :notes]
  end
end
