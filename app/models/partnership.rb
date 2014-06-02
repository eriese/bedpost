# == Schema Information
#
# Table name: partnerships
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  partner_id  :integer
#  familiarity :integer
#  exclusivity :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Partnership < ActiveRecord::Base
  attr_accessible :exclusivity, :familiarity, :partner_id, :user_id, :exclusivity, :communication
  belongs_to :user, class_name: "Profile",foreign_key: "user_id"
  belongs_to :partner, class_name: "Profile", foreign_key: "partner_id"

  def find_partner(uid)
    self.partner = Profile.where(uid: uid).first
  end
end
