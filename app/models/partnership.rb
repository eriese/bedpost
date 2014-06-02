class Partnership < ActiveRecord::Base
  attr_accessible :exclusivity, :familiarity, :partner_id, :user_id
  belongs_to :user, class_name: "Profile",foreign_key: "user_id"
  belongs_to :partner, class_name: "Profile", foreign_key: "partner_id"
end
