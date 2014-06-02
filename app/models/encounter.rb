class Encounter < ActiveRecord::Base
  attr_accessible :fluid, :notes, :partner_id, :self_risk, :took_place, :user_id
end
