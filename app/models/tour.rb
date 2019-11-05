class Tour
  include Mongoid::Document
  include StaticResource
  field :page_name, type: String
  embeds_many :tour_nodes

  index({page_name: 1}, {unique: true})

  #search by page and cache
  def self.by_page(page_name)
  	find_cached(page_name, field: :page_name)
  end

  #search and cache a page without throwing an error if it doesn't exist
  def self.by_page!(page_name)
  	by_page(page_name)
  rescue Mongoid::Errors::DocumentNotFound
  	false
  end
end
