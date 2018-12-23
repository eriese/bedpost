class Partnership
  include Mongoid::Document
  field :familiarity, type: Integer
  field :exclusivity, type: Integer
  field :communication, type: Integer

  embedded_in :user_profile
  belongs_to :partner, class_name: "Profile"

  validates :partner, uniqueness: true, exclusion: {in: ->(partnership) {[partnership.user_profile]}}
end
