class Tour
  include Mongoid::Document
  include StaticResource
  field :page_name, type: String
  embeds_many :tour_nodes

  index({page_name: 1}, {unique: true})
end
