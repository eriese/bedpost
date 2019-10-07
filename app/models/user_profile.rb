class UserProfile < Profile
  # include ActiveModel::SecurePassword
  #to allow for serialization for jobs
  include GlobalID::Identification
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :confirmable,
         :lockable, :timeoutable, :trackable

  ## Database authenticatable
  field :email, type: String, default: ""
  field :encrypted_password, type: String, default: ""

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  # field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  field :locked_at,       type: Time

  ## Bedpost
  field :uid, type: String, default: ->{generate_uid}
  field :min_window, type: Integer, default: 6
  index({email: 1}, {unique: true})
  index({uid: 1}, {unique: true})

  # has_secure_password
  # attr_accessor :old_password

  has_many :user_tokens

  embeds_many :partnerships, cascade_callbacks: true

  validates_presence_of :password, :password_confirmation, on: :create
  # validate :update_secure_only_with_password, on: :update
  validates_uniqueness_of :uid, :email, case_sensitive: false
  validates_presence_of :email, :encrypted_password, :uid
  validates_presence_of :pronoun, :anus_name, :external_name, on: :update
  validates :password, length: {minimum: 7, maximum: 72}, allow_blank: true


  after_create {SendWelcomeEmailJob.perform_later(self)}

  def email=(value)
  	super(value.downcase) unless value == nil
  end

  def update_only_password(new_pass)
    self.password = new_pass
    return password_valid? && save(validate: false)
  end

  def as_json(options = {})
    options[:except] ||= []
    options[:except] << :encrypted_password
    super
  end

  def encounters
    enc = []
    partnerships.each {|p| enc += p.encounters}
    enc
  end

  def self.find_by_email(email)
    find_by(email: email.downcase)
  end

  private
  def generate_uid
  	SecureRandom.uuid.slice(0,8)
  end

  def password_valid?
    self.class.validators_on(:password).each do |validator|
      validator.validate_each(self, :password, self.password)
      unless errors[:password].none?
        return false
      end
    end

    true
  end

  def secure_changed?
    password_digest_changed? || email_changed?
  end

  def secure_password_changed?
    password_digest_changed? && old_password.present? && BCrypt::Password.new(password_digest_was).is_password?(old_password)
  end

  def secure_no_password_changed?
    !password_digest_changed? && authenticate(old_password)
  end

  def update_secure_only_with_password
    return unless secure_changed?
    errors.add(:old_password, :invalid) unless secure_password_changed? || secure_no_password_changed?
  end

end
