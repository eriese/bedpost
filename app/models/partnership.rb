class Partnership < ActiveRecord::Base
  attr_accessible :exclusivity, :familiarity, :partner_id, :user_id
end
