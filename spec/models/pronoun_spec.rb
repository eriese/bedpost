require 'rails_helper'

RSpec.describe Pronoun, type: :model do
	it 'has a working factory' do
		build_stubbed(:pronoun)
	end
end
