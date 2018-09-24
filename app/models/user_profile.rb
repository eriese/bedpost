class UserProfile < Profile
  include ActiveModel::SecurePassword
  field :email, type: String
  field :password_digest, type: String
  field :uid, type: String
  field :min_window, type: Integer, default: 6

  has_secure_password
  validates_uniqueness_of :uid, message: "That partnering ID is unavailable. Please try a different one.", case_sensitive: false

  def UserProfile.make_user()
  	profile.type = "UserProfile"
end
