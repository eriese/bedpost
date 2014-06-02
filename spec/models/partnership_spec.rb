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

require 'spec_helper'

describe Partnership do
  pending "add some examples to (or delete) #{__FILE__}"
end
