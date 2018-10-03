class UserProfile < Profile
  include ActiveModel::SecurePassword
  include DeAliasFields

  field :email, type: String
  field :password_digest, type: String
  field :uid, type: String, default: ->{generate_uid}
  field :min_window, type: Integer, default: 6

  has_secure_password
  validates_uniqueness_of :uid, message: "That partnering ID is unavailable. Please try a different one.", case_sensitive: false
  validates_uniqueness_of :email, case_sensitive: false
  validates_presence_of :email, :password_digest, :uid
  validates_presence_of :pronoun, :anus_name, :external_name, on: :update

  def email=(value)
  	super(value.downcase) unless value == nil
  end

  private
  def generate_uid
  	SecureRandom.uuid.slice(0,8)
  end
end
