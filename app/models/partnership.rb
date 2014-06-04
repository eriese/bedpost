# == Schema Information
#
# Table name: partnerships
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  partner_id    :integer
#  familiarity   :integer
#  exclusivity   :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  communication :integer
#

class Partnership < ActiveRecord::Base
  attr_accessible :exclusivity, :familiarity, :partner_id, :user_id, :exclusivity, :communication
  belongs_to :user, class_name: "Profile",foreign_key: "user_id"
  belongs_to :partner, class_name: "Profile", foreign_key: "partner_id"
  validates_uniqueness_of :user_id, :scope => :partner_id, message: "You have already registered this partnership."

  def find_partner(uid)
    self.partner = Profile.where(uid: uid).first
  end
  def riskiness
    @risk = 0
    @risk += 10 - self.exclusivity
    @risk += 10 - self.familiarity
    @risk += 10 - self.communication
    return @risk
  end
  def encounters
    Encounter.where({user_id: self.user_id, partner_id: self.partner_id}).order("took_place DESC")
  end
  def most_recent
    self.encounters.first
  end
  def at_risk?(disease_name)
    if self.most_recent
      if self.user.risk_window(disease_name)
        return self.user.risk_window(disease_name) <= self.most_recent.took_place
      else
        return true
      end
    else
      return false
    end
  end
end
