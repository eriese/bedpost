class TourNode
  include Mongoid::Document
  field :target, type: String
  field :position, type: Integer
  field :body, type: String

  embedded_in :tour
end
