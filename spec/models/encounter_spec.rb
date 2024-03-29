require 'rails_helper'

RSpec.describe Encounter, type: :model do
	context '#contacts' do
		before :all do
			@user = create(:user_profile)
			@ship = build(:partnership, partner: create(:profile))
			@user.partnerships << @ship

			@hand = create(:contact_instrument, name: :hand)
			@genitals = create(:contact_instrument, name: :genitals)
			@possible1 = create(:possible_contact, contact_type: :touched, subject_instrument: @hand, object_instrument: @hand)
			@possible2 = create(:possible_contact, contact_type: :touched, subject_instrument: @hand,
																																										object_instrument: @genitals)
		end

		after :each do
			cleanup(*@ship.encounters)
		end

		after :all do
			cleanup(@user, @possible1, @possible2, @hand, @genitals)
		end

		it 'accepts nested attributes' do
			enc = build(:encounter, partnership: @ship, user_profile: @user)
			expect(enc).to respond_to :contacts_attributes=
			new_attrs = [
				attributes_for(:encounter_contact, possible_contact: @possible1),
				attributes_for(:encounter_contact, possible_contact: @possible2)
			]
			result = enc.update_attributes(contacts_attributes: new_attrs)

			expect(result).to be true
			expect(enc.reload.contacts.size).to eq 2
		end
	end
end
