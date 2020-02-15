class BetaToken
	include Mongoid::Document
	field :email
	field :token, type: String, default: -> { SecureRandom.uuid.slice(0...8).downcase }

	validates_uniqueness_of :email, allow_nil: false

	def email=(value)
		super(value.nil? ? value : value.downcase)
	end

	def self.find_token(token_val)
		find_by(token: token_val.downcase)
	end
end
