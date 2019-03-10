class UserProfile < Profile
  include ActiveModel::SecurePassword
  #to allow for serialization for jobs
  include GlobalID::Identification

  field :email, type: String
  field :password_digest, type: String
  field :uid, type: String, default: ->{generate_uid}
  field :min_window, type: Integer, default: 6
  index({email: 1}, {unique: true})
  index({uid: 1}, {unique: true})

  has_secure_password
  has_many :user_tokens

  embeds_many :partnerships, cascade_callbacks: true

  validates_uniqueness_of :uid, :email, case_sensitive: false
  validates_presence_of :email, :password_digest, :uid
  validates_presence_of :pronoun, :anus_name, :external_name, on: :update
  validates :password, length: {minimum: 7}, confirmation: {case_sensitive: true}, allow_nil: true

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
    options[:except] << :password_digest
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
end
