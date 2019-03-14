require 'rails_helper'

RSpec.describe Encounter, type: :model do
  context '#contacts' do
  	before :all do
  		@user = create(:user_profile)
  		@ship = build(:partnership, partner: create(:profile))
  		@user.partnerships << @ship

  		@hand = create(:contact_instrument, name: :hand)
  		@genitals = create(:contact_instrument, name: :genitals)
  		@hand.can_touch << @genitals
  		@hand.can_touch << @hand
  	end

  	after :each do
  		cleanup(*@ship.encounters)
  	end

  	after :all do
  		cleanup(@user, @hand, @genitals)
  	end

  	it 'accepts nested attributes' do
  		enc = create(:encounter, partnership: @ship)
  		expect(enc).to respond_to :contacts_attributes=
  		result = enc.update_attributes(contacts_attributes: [
  			attributes_for(:contact, partner_instrument: @hand, self_instrument: @hand),
  			attributes_for(:contact, partner_instrument: @genitals, self_instrument: @hand)
  		])

  		expect(result).to be true
  		expect(enc.reload.contacts.size).to eq 2
  	end
  end
end
