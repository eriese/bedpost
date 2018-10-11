class UserProfile < Profile
  include ActiveModel::SecurePassword
  #to allow for serialization for jobs
  include GlobalID::Identification
  include DeAliasFields

  field :email, type: String
  field :password_digest, type: String
  field :uid, type: String, default: ->{generate_uid}
  field :min_window, type: Integer, default: 6
  index({email: 1})

  has_secure_password
  has_many :user_tokens

  validates_uniqueness_of :uid, message: "That partnering ID is unavailable. Please try a different one.", case_sensitive: false
  validates_uniqueness_of :email, case_sensitive: false
  validates_presence_of :email, :password_digest, :uid
  validates_presence_of :pronoun, :anus_name, :external_name, on: :update

  after_create {SendWelcomeEmailJob.perform_later(self)}

  def email=(value)
  	super(value.downcase) unless value == nil
  end

  def self.find_by_email(email)
    UserProfile.find_by(email: email.downcase)
  end

  private
  def generate_uid
  	SecureRandom.uuid.slice(0,8)
  end
end
