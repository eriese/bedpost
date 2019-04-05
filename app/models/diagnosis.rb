class Diagnosis
  include Mongoid::Document

  field :name, type: Symbol
  field :_id, type: Symbol, default: ->{ name }
  field :gestation_min, type: Integer
  field :gestation_max, type: Integer
  field :barriers_effective, type: Boolean
  field :category, type: Array

  has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'
end
