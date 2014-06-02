# == Schema Information
#
# Table name: infections
#
#  id          :integer          not null, primary key
#  disease     :string(255)
#  positive    :boolean
#  sti_test_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Infection < ActiveRecord::Base
  attr_accessible :disease, :positive, :sti_test_id
  belongs_to :sti_test
end
