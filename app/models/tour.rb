class Tour
  include Mongoid::Document
  include StaticResource
  field :page_name, type: String
  embeds_many :tour_nodes

  index({page_name: 1}, {unique: true})

  def self.by_page(page_name)
  	find_cached(page_name, field: :page_name)
  end

  def self.tour_exists?(page_name)
  	by_page(page_name)
  rescue Mongoid::Errors::DocumentNotFound
  	false
  end
end
