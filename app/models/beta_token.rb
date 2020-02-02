class BetaToken
	include Mongoid::Document
	field :email
	field :token, type: String, default: -> {SecureRandom.uuid.slice(0...8)}

	validates_uniqueness_of :email, allow_nil: false

	def email=(value)
		super(value.nil? ? value : value.downcase)
	end
end
