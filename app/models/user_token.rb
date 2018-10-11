class UserToken
  include Mongoid::Document
  belongs_to :user_profile
  field :token_type, type: String
  field :_id, type: String, default: -> {SecureRandom.uuid}

  index({user_profile_id: 1, _id: 1}, {unique: true})



  def self.reset_token(user_id)
  	UserToken.new(user_profile_id: user_id, token_type: "reset")
  end

  def self.reset_token!(user_id)
  	create(user_profile_id: user_id, token_type: "reset")
  end

  def self.with_user(token_id, user_id)
    token = find(token_id)
    token.user_profile_id == user_id ? token : nil
  end
end
