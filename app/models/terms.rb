class Terms
	include Mongoid::Document
	include Mongoid::Timestamps::Short
	include StaticResource

	field :terms, type: String
	field :type, type: Symbol

	index({updated_at: -1, type: 1})

	def self.newest_of_type(type_to_get)
		newest(type: type_to_get)
	end
end
