class Contact < ActiveRecord::Base
  attr_accessible :encounter_id, :partner_inst, :user_inst
end
