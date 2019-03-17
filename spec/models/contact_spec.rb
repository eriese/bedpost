require 'rails_helper'

RSpec.describe Contact, type: :model do
	context 'validation' do
		describe 'validates that the contact type is possible for the given instruments' do
			before :all do
				@hand = create(:contact_instrument, name: :hand)
	  		@genitals = create(:contact_instrument, name: :genitals)
	  		@hand.can_penetrate << @genitals
			end

			after :all do
				cleanup(@hand, @genitals)
			end

			it 'does not allow impossible instruments' do
				contact = build(:contact, contact_type: :penetrated_by, self_instrument: @hand, partner_instrument: @genitals)
				expect(contact).to_not be_valid
				expect(contact).to have_validation_error_for(:contact_type, :invalid)
			end

			it 'does allow possible instruments' do
				contact = build(:contact, contact_type: :penetrated_by, partner_instrument: @hand, self_instrument: @genitals)
				expect(contact).to be_valid
			end
		end
	end

	context 'methods' do
		describe '#serializable_hash' do
			it 'includes #contact_type as just its key' do
				contact = build(:contact)
				result = contact.serializable_hash
				expect(result[:contact_type]).to eq contact.contact_type.key
			end

			it 'does not include #contact_type if it was in the given exclude list' do
				contact = build(:contact)
				result = contact.serializable_hash({except: [:contact_type]})
				expect(result).to_not have_key(:contact_type)
			end
		end
	end
end
