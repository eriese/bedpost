class UserProfile < Profile
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable,
				 :recoverable, :validatable, :confirmable,
				 :lockable, :timeoutable, :trackable

	## Database authenticatable
	field :email,                  type: String, default: ''
	field :encrypted_password,     type: String, default: ''

	## Recoverable
	field :reset_password_token,   type: String
	field :reset_password_sent_at, type: Time

	## Trackable
	field :sign_in_count,          type: Integer, default: 0
	field :current_sign_in_at,     type: Time
	field :last_sign_in_at,        type: Time
	field :current_sign_in_ip,     type: String
	field :last_sign_in_ip,        type: String

	## Confirmable
	field :confirmation_token,     type: String
	field :confirmed_at,           type: Time
	field :confirmation_sent_at,   type: Time
	# field :unconfirmed_email,    type: String # Only if using reconfirmable

	## Lockable
	field :failed_attempts,        type: Integer, default: 0 # Only if lock strategy is :failed_attempts
	field :unlock_token,           type: String # Only if unlock strategy is :email or :both
	field :locked_at,              type: Time

	## Soft delete
	field :deleted_at,             type: Time

	## Bedpost
	field :uid,                    type: String, default: -> { generate_uid }
	field :min_window,             type: Integer, default: 6
	field :opt_in,                 type: Boolean, default: false
	field :first_time,             type: Boolean, default: true
	field :terms,                  type: Hash
	field :tours,                  type: Set

	index({ email: 1 }, unique: true, sparse: true)
	index({ uid: 1 }, unique: true, sparse: true)

	embeds_many :partnerships, cascade_callbacks: true

	validates_presence_of :password, :password_confirmation, on: :create
	validates_uniqueness_of :uid, case_sensitive: false
	validates_presence_of :email, :encrypted_password, :uid, if: :active_for_authentication?
	validates_presence_of :pronoun, :anus_name, :external_name, on: :update

	BLACKLIST_FOR_SERIALIZATION += %i[partnerships password_digest tours]

	def email=(value)
		super(value.downcase) unless value == nil
	end

	def encounters
		enc = []
		partnerships.each { |p| enc += p.encounters }
		enc
	end

	# TODO: implement this when implementing risk-to-partner calculations. take user's activities, risk-taking behavior, results, etc. into account
	def risk_mitigator
		0
	end

	# Is the user's profile fully set up?
	# @return [true] if the user has completed full profile setup
	def set_up?
		pronoun_id.present?
	end

	# Is this the user's first time using the app?
	# @return [true] if the user has not completed any actions that set first_time to false
	def first_time?
		first_time
		# true
	end

	# Has the user been given a tour of the given page?
	# @param [String] page the page url
	# @return [true] if the user has toured the page
	def has_toured?(page)
		tours.present? && tours.include?(page)
	end

	# Mark the user as having toured the given page
	# @param [String] page the page url
	# @return [true] if the user was saved properly
	def tour(page)
		tmp = self.tours
		tmp << page
		self.tours = tmp
		changed? ? save : true
	end

	# Did this user accept the given terms after the most recent update of those terms?
	def terms_accepted?(terms_type)
		newest_terms = Terms.newest_of_type(terms_type)
		terms_accepted = terms && terms[terms_type]
		terms_accepted.present? && terms_accepted >= newest_terms.updated_at
	end

	# Accept the given terms type
	def accept_terms(terms_type, opt_in_val = nil)
		self.terms ||= {}
		self.terms[terms_type] = DateTime.now
		self.opt_in = opt_in_val unless opt_in_val.nil?
		save(validate: false)
	end

	# An aggregate query to get the user's partnerships (including partner names) sorted by most-recent encounter
	def partners_with_most_recent
		UserProfile.collection.aggregate(partners_lookup + [
			{'$project' => {
				most_recent: {'$max' => '$encounters.took_place'},
				nickname: 1,
				partner_name: {'$arrayElemAt' => ['$partner.name', 0]}
			}},
			{'$sort' => {most_recent: -1}}
		])
	end

	# An aggregate query to get the user's partnerships (including partner names) with all of their encounters
	def partners_with_encounters(partnership_id = nil)
		lookup = partners_lookup
		if partnership_id
			partnership_id = BSON::ObjectId(partnership_id) unless partnership_id.is_a? BSON::ObjectId
			lookup.insert(lookup_index, {'$match' => {'_id' => partnership_id}})
		else
			lookup.insert(lookup_index, {'$redact' => {
				'$cond' => {
					if: {'$and' => [{'$isArray' => '$encounters'}, {'$gt' => [{'$size' => '$encounters'}, 0]}]},
					then: '$$KEEP',
					else: '$$PRUNE'
					}
				}
			})
		end

		UserProfile.collection.aggregate(lookup + [
			{'$project' => {
				encounters: {took_place: 1, notes: 1, _id: 1},
				nickname: 1,
				partner_name: {'$arrayElemAt' => ['$partner.name', 0]}
			}},
		])
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
			update_attribute(:email, '')
			true
		else
			replace_with_dummy
			destroy
		end
	end

	def timeout_in
		Rails.env.development? ? 1.year : 30.minutes
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
		if 	access_locked? ||
				(lock_strategy_enabled?(:failed_attempts) && attempts_exceeded?)
			:locked
		elsif	lock_strategy_enabled?(:failed_attempts) &&
					last_attempt? &&
					self.class.last_attempt_warning
			:last_attempt
		else
			super
		end
	end

	def send_devise_notification(notification, *args)
		logger.debug "queueing devise notification #{notification} with args #{args}"
		queued = devise_mailer.delay(queue: 'devise_notifications')
		queued.send(notification, self, *args)
	end

	private

	def generate_uid
		SecureRandom.uuid.slice(0,8)
	end

	def replace_with_dummy
		return unless partnered_to_ids.any?

		dummy = Profile.create(
			name: name,
			anus_name: anus_name,
			external_name: external_name,
			internal_name: internal_name,
			can_penetrate: can_penetrate,
			pronoun_id: pronoun_id
		)
		# TODO: this can probably be optimized
		UserProfile.find(partnered_to_ids).each do |u|
			found_partners = u.partnerships.find_by({ partner_id: id })
			found_partners.update({ partner_id: dummy.id })
		end
	end

	# an aggregation query pipeline that uses a lookup to join with the partners' profiles
	def partners_lookup
		[
			{ '$match' => { '_id' => id } },
			{ '$unwind' => '$partnerships' },
			{ '$replaceRoot' => { newRoot: '$partnerships' } },
			{ '$lookup' => {
				from: 'profiles',
				localField: 'partner_id',
				foreignField: '_id',
				as: 'partner'
			} }
		]
	end

	def lookup_index
		partners_lookup.index { |q| q.key? '$lookup' }
	end
end
