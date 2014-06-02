class Infection < ActiveRecord::Base
  attr_accessible :disease, :positive, :sti_test_id
  belongs_to :sti_test
end
