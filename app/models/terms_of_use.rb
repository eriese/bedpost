class TermsOfUse
	include Mongoid::Document
	include Mongoid::Timestamps::Short
	include StaticResource

	field :terms, type: String
end
