class Contact < ActiveRecord::Base
  attr_accessible :encounter_id, :partner_inst, :user_inst, :barriers
  belongs_to :encounter_id
  validates :user_inst, :partner_inst, :presence => true
end
