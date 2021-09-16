class UserProfile < Profile
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable,
								:recoverable, :validatable,
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
	# field :confirmation_token,     type: String
	# field :confirmed_at,           type: Time
	# field :confirmation_sent_at,   type: Time
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
	index({ uid: 1 }, unique: true, sparse: true, collation: { locale: I18n.default_locale.to_s, strength: 2 })

	embeds_many :partnerships, cascade_callbacks: true
	embeds_many :encounters, cascade_callbacks: true
	embeds_many :sti_tests, order: :tested_on.desc, cascade_callbacks: true

	validates_presence_of :password, :password_confirmation, on: :create
	validates_uniqueness_of :uid, case_sensitive: false
	validates_presence_of :email, :encrypted_password, :uid, if: :active_for_authentication?
	validates_presence_of :pronoun, :anus_name, :external_name, on: :update
	validates_confirmation_of :password

	BLACKLIST_FOR_SERIALIZATION = %i[partnerships password_digest tours]

	after_create do |user|
		if ENV['IS_BETA']
			beta_token = BetaToken.where(email: user.email).first
			beta_token.destroy unless beta_token.nil?
		end
	end

	def email=(value)
		super(value.nil? ? value : value.downcase)
	end

	# TODO: implement this when implementing risk-to-partner calculations. take user's activities, risk-taking behavior, results, etc. into account
	def risk_mitigator
		0
	end

	# Is the user's profile fully set up?
	# @return [true] if the user has completed full profile setup
	def set_up?
		pronoun_id.present?
		# false
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
	def has_toured?(page, fte_only)
		tours.present? && tours.include?("#{page}-#{fte_only}")
		# false
	end

	# Mark the user as having toured the given page
	# @param [String] page the page url
	# @return [true] if the user was saved properly
	def tour(page, fte_only)
		tmp = self.tours
		tmp << "#{page}-#{fte_only}"
		self.tours = tmp
		changed? ? save : true
	end

	# Did this user accept the given terms after the most recent update of those terms?
	def terms_accepted?(terms_type)
		newest_terms = Terms.newest_of_type(terms_type)
		return true unless newest_terms.present?

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

	def partner_elem(partner_field)
		"$partner.#{partner_field}"
	end

	# An aggregate query to get the user's partnerships (including partner names) sorted by most-recent encounter
	def partners_with_most_recent
		UserProfile.collection.aggregate(partners_lookup(true) + [
			{ '$project' => {
				most_recent: { '$max' => '$encounters.took_place' },
				nickname: 1,
				partner_name: partner_elem('name')
			} },
			{ '$sort' => { most_recent: -1 } }
		])
	end

	def partners_with_profiles
		UserProfile.collection.aggregate(partners_lookup + [
			{
				'$project': {
					name: partner_elem('name'),
					pronoun_id: partner_elem('pronoun_id'),
					anus_name: partner_elem('a_n'),
					external_name: partner_elem('e_n'),
					internal_name: partner_elem('i_n'),
					can_penetrate: partner_elem('c_p'),
					partner_name: { '$concat': [partner_elem('name'), ' ', '$nickname'] }
				}
			}
		])
	end

	# An aggregate query to get the user's partnerships (including partner names) with all of their encounters
	def partners_with_encounters(partnership_id = nil)
		lookup = partners_lookup(true)
		if partnership_id.present?
			partnership_id = BSON::ObjectId(partnership_id) unless partnership_id.is_a? BSON::ObjectId
			lookup.insert(lookup_index(lookup), { '$match' => { '_id' => partnership_id } })
		else
			lookup << { '$redact' => {
				'$cond' => {
					if: { '$and' => [{ '$isArray' => '$encounters' }, { '$gt' => [{ '$size' => '$encounters' }, 0] }] },
					then: '$$KEEP',
					else: '$$PRUNE'
				}
			} }
		end

		UserProfile.collection.aggregate(lookup + [
			{ '$project' => {
				encounters: { took_place: 1, notes: 1, _id: 1, partnership_id: 1 },
				nickname: 1,
				partner_name: '$partner.name'
			} }
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
		destroyed = false
		if opt_in
			new_identifier = generate_uid
			destroyed = update(
				deleted_at: Time.current,
				email: "#{new_identifier}@bedpost.me",
				name: new_identifier,
				uid: new_identifier
			)
		else
			replace_with_dummy
			destroyed = destroy
		end
		RegistrationMailer.removal(id.to_s, email, name, opt_in).deliver_later if destroyed

		destroyed
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
		if	access_locked? ||
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

	def self.where_partnered_to(profile_id)
		where('partnerships.partner_id' => profile_id)
	end

	def self.with_uid(uid)
		collation(locale: I18n.default_locale.to_s, strength: 2)
			.where(uid: uid).first
	end

	private

	def generate_uid
		SecureRandom.uuid.slice(0, 8)
	end

	def replace_with_dummy
		partners = UserProfile.where_partnered_to(id)
		return unless partners.any?

		dummy = Profile.create(
			name: name,
			anus_name: anus_name,
			external_name: external_name,
			internal_name: internal_name,
			can_penetrate: can_penetrate,
			pronoun_id: pronoun_id
		)
		# TODO: this can probably be optimized
		partners.each do |u|
			found_partner = u.partnerships.find_by({ partner_id: id })
			found_partner.update({ partner_id: dummy.id })
		end
	end

	# an aggregation query pipeline that uses a lookup to join with the partners' profiles
	def partners_lookup(include_encounters = false)
		actions = [
			{ '$match' => { '_id' => id } },
			{ '$unwind' => '$partnerships' }
		]
		new_root =
			if include_encounters
				{
					'$mergeObjects': ['$partnerships', { 'encounters': {
						'$filter': {
							input: '$encounters', as: 'enc', cond: { '$eq' => ['$$enc.partnership_id', '$partnerships._id'] }
						}
					} }]
				}
			else
				'$partnerships'
			end

		actions + [
			{ '$replaceRoot' => { newRoot: new_root } }
		] + [
			{ '$lookup' => {
				from: 'profiles',
				localField: 'partner_id',
				foreignField: '_id',
				as: 'partner'
			} },
			{ '$unwind' => '$partner' }
		]
	end

	def lookup_index(pipeline)
		pipeline.index { |q| q.key? '$lookup' }
	end
end
