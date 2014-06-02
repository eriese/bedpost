# == Schema Information
#
# Table name: encounters
#
#  id         :integer          not null, primary key
#  fluid      :boolean
#  notes      :text
#  self_risk  :integer
#  took_place :date
#  user_id    :integer
#  partner_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Encounter do
  pending "add some examples to (or delete) #{__FILE__}"
end
