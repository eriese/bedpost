class Partnership
  include Mongoid::Document
  field :nickname, type: String
  field :familiarity, type: Integer, default: 1
  field :exclusivity, type: Integer, default: 1
  field :communication, type: Integer, default: 1

  embedded_in :user_profile
  belongs_to :partner, class_name: "Profile"

  index({partner_id: 1}, {unique: true})

  validates :partner, uniqueness: true, not_self: true
  validates :uid,
  	foreign_key: {key_class: UserProfile},
  	not_self: {method: :uid},
  	exclusion: {in: ->(partnership) {partnership.user_profile.partnerships.map { |ship| ship == partnership ? nil : ship.uid }}, message: :taken},
  	allow_nil: true

  def uid
  	@uid ||= (ptnr = self.partner; ptnr.uid if ptnr.respond_to?(:uid))
  end

  def uid=(value)
  	value.downcase!
  	ptnr = UserProfile.where({uid: value}).first
  	self.partner = ptnr if (ptnr && ptnr != user_profile)
  	@uid = value if ptnr || self.partner_id.nil?
	end

	def serializable_hash(options)
		super.merge({uid: uid})
	end
end
