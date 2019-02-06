class Partnership
  include Mongoid::Document
  LEVEL_FIELDS = [:familiarity, :exclusivity, :communication, :trust, :prior_discussion]
  field :nickname, type: String

  LEVEL_FIELDS.each do |f|
  	field f, type: Integer, default: 1
  	validates f, numericality: {only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10}
  end

  embedded_in :user_profile
  belongs_to :partner, class_name: "Profile"

  index({partner_id: 1}, {unique: true})

  validates :partner, uniqueness: true, not_self: true
  validates :uid,
  	foreign_key: {key_class: UserProfile},
  	not_self: {method: :uid},
  	exclusion: {in: ->(partnership) {partnership.user_profile.partnerships.map { |ship| ship == partnership ? nil : ship.uid }}, message: :taken},
  	allow_nil: true

  # validates :nickname, presence: true

  before_save :add_to_partner
  before_destroy :remove_from_partner

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

	def update_partner(partner_param)
		old_partner = partner
		did_update = update(partner_param)
		if did_update && old_partner.is_base?
			old_partner.destroy
		end
		did_update
	end

	def serializable_hash(options)
		super.merge({uid: uid})
	end

	private
	def add_to_partner
		if partner_id_changed?
			new_partner = Profile.find(partner_id)
			new_partner.partnered_to ||= []
			new_partner.partnered_to.push(user_profile)
			remove_from_partner(partner_id_was)
		end
	end

	def remove_from_partner(prev_partner = partner_id)
		unless prev_partner.nil?
			old_partner = Profile.find(prev_partner)
			old_partner.partnered_to.delete(user_profile)
		end
	end

end
