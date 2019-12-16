class TourNode
	include Mongoid::Document
	field :target, type: String
	field :position, type: Integer
	field :content, type: String, localize: true

	index "content.en" => 1

	embedded_in :tour
end
