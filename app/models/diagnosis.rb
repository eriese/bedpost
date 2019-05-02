class Diagnosis
  include Mongoid::Document
  include StaticResource

  field :name, type: Symbol
  field :_id, type: Symbol, default: ->{ name }
  field :gestation_min, type: Integer
  field :gestation_max, type: Integer
  field :in_fluids, type: Boolean
  field :category, type: Array

  has_many :transmission_risks, class_name: 'Diagnosis::TransmissionRisk'

end
