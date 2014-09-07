# == Schema Information
#
# Table name: contacts
#
#  id           :integer          not null, primary key
#  user_inst    :string(255)
#  partner_inst :string(255)
#  encounter_id :integer
#  barriers     :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Contact < ActiveRecord::Base
  attr_accessible :encounter_id, :partner_inst, :user_inst, :barriers
  belongs_to :encounter
  validates :user_inst, :partner_inst, :presence => true
  def get_risks()
    disease_list = Disease.risk_by_contact({user_instrument: self.user_inst, partner_instrument: self.partner_inst, barriers?: self.barriers})
  end
end
