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

require 'spec_helper'

describe Contact do
  pending "add some examples to (or delete) #{__FILE__}"
end
