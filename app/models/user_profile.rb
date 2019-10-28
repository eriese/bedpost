class UserProfile < Profile
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

  ## Soft delete
  field :deleted_at,      type: Time

  ## Bedpost
  field :uid, type: String, default: ->{generate_uid}
  field :min_window, type: Integer, default: 6
  field :opt_in, type: Boolean, default: false
  index({email: 1}, {unique: true})
  index({uid: 1}, {unique: true})

  has_many :user_tokens

  embeds_many :partnerships, cascade_callbacks: true

  validates_presence_of :password, :password_confirmation, on: :create
  validates_uniqueness_of :uid, case_sensitive: false
  validates_presence_of :email, :encrypted_password, :uid, if: :active_for_authentication?
  validates_presence_of :pronoun, :anus_name, :external_name, on: :update

  BLACKLIST_FOR_SERIALIZATION += [:partnerships, :password_digest]

  def email=(value)
  	super(value.downcase) unless value == nil
  end

  def encounters
    enc = []
    partnerships.each {|p| enc += p.encounters}
    enc
  end

  #TODO implement this when implementing risk-to-partner calculations. take user's activities, risk-taking behavior, results, etc. into account
  def risk_mitigator
    0
  end

  def set_up?
    pronoun_id.present?
  end

  def first_time?
    !embedded_relations.any? { |k, e| send(e.store_as).any? }
    # true
  end

  def update_without_password(params, *options)
    params.delete(:email)
    params.delete(:current_password)
    super(params)
  end

  def destroy_with_password(current_password)
    result = if valid_password?(current_password)
      soft_destroy
    else
      valid?
      errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    result
  end

  def soft_destroy
    if opt_in
      update_attribute(:deleted_at, Time.current)
      update_attribute(:email, "")
      true
    else
      replace_with_dummy
      destroy
    end
  end

  def encode_with(coder)
    super
    coder['attributes'] = @attributes.except *BLACKLIST_FOR_SERIALIZATION
  end

  def active_for_authentication?
    super && deleted_at.nil?
  end

  def inactive_message
    !deleted_at ? super : :deleted_account
  end

  def unauthenticated_message
    if access_locked? || (lock_strategy_enabled?(:failed_attempts) && attempts_exceeded?)
      :locked
    elsif lock_strategy_enabled?(:failed_attempts) && last_attempt? && self.class.last_attempt_warning
      :last_attempt
    else
      super
    end
  end

  def send_devise_notification(notification, *args)
    logger.debug "queueing devise notification #{notification} with args #{args}"
    devise_mailer.delay(queue: 'devise_notifications').send(notification, self, *args)
  end

  private
  def generate_uid
  	SecureRandom.uuid.slice(0,8)
  end

  def replace_with_dummy
    return unless partnered_to_ids.any?
    dummy = Profile.create(name: name, anus_name: anus_name, external_name: external_name, internal_name: internal_name, can_penetrate: can_penetrate, pronoun_id: pronoun_id)
    # TODO this can probably be optimized
    UserProfile.find(partnered_to_ids).each {|u| u.partnerships.find_by({partner_id: id}).update({partner_id: dummy.id})}
  end
end
