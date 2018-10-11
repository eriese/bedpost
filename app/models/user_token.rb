class UserToken
  include Mongoid::Document
  belongs_to :user_profile
  field :token_type, type: String
  field :_id, type: String, default: -> {SecureRandom.uuid}

  def self.reset_token(userID)
  	UserToken.new(user_profile_id: userID, token_type: "reset")
  end

  def self.reset_token!(userID)
  	UserToken.create(user_profile_id: userID, token_type: "reset")
  end
end
