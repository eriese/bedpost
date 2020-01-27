class TourNode
	include Mongoid::Document
	field :target, type: String
	field :position, type: Integer
	field :await_in_view, type: Boolean, default: false
	field :content, type: String, localize: true

	index "content.en" => 1

	embedded_in :tour
end
