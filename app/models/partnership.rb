class Partnership
	include Mongoid::Document
	LEVEL_FIELDS = [:familiarity, :exclusivity, :communication, :trust, :prior_discussion]
	field :nickname, type: String

	LEVEL_FIELDS.each do |f|
		field f, type: Integer, default: 1
		validates f, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10}
	end

	embedded_in :user_profile
	embeds_many :encounters
	belongs_to :partner, class_name: "Profile"

	index({partner_id: 1}, {unique: true})

	validates :partner, uniqueness: true, not_self: true
	validates :uid,
		foreign_key: {key_class: UserProfile},
		not_self: {method: :uid},
		exclusion: {in: ->(ship) {Profile.find(ship.user_profile.partnerships.map { |s| s.partner_id unless s == ship}.compact).pluck(:uid).compact}, message: :taken},
		allow_nil: true

	after_save :add_to_partner
	before_destroy :remove_from_partner

	accepts_nested_attributes_for :partner

	def uid
		@uid ||= (ptnr = self.partner; ptnr.uid if ptnr.respond_to?(:uid))
	end

	def uid=(value)
		return unless value.present?
		value.downcase!
		ptnr = UserProfile.where({uid: value}).first
		self.partner = ptnr if (ptnr && ptnr != user_profile)
		@uid = value if ptnr || self.partner_id.nil?
	end

	def last_took_place(if_none = nil)
		encounters.any? ? encounters.last.took_place : (if_none.nil? ? Date.today : if_none)
	end

	def display(partner_name = nil)
		self.class.make_display(partner_name || partner.name, nickname)
	end

	def risk_mitigator
		return @risk_mitigator unless @risk_mitigator.nil?
		@risk_mitigator = 0
		@risk_mitigator += 2 * trust
		@risk_mitigator += 2 * exclusivity
		@risk_mitigator += familiarity
		@risk_mitigator += communication
		@risk_mitigator += prior_discussion
		@risk_mitigator /= 14.0
		@risk_mitigator = @risk_mitigator.ceil - 1
	end

	def any_level_changed?
		any_changed = false
		LEVEL_FIELDS.each do |f|
			if changes[f]
				any_changed = true
				break
			end
		end
		any_changed
	end

	def self.make_display(partner_name, nickname)
		"#{partner_name} #{nickname}"
	end

	private
	def add_to_partner
		@risk_mitigator = nil if any_level_changed?
		post_persist
		if prev_partner_changes = previous_changes[:partner_id]
			prev_partner = prev_partner_changes[0]
			remove_from_partner(prev_partner)
		end
	end

	def remove_from_partner(prev_partner = partner_id)
		RemoveOrphanedProfileJob.perform_later(prev_partner.to_s) unless prev_partner.nil?
	end

end
