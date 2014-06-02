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

require 'spec_helper'

describe Infection do
  pending "add some examples to (or delete) #{__FILE__}"
end
