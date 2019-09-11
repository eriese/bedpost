require 'rails_helper'

RSpec.describe PossibleContact, type: :model do
  context 'class methods' do
  	before :all do
      PossibleContact.instance_variable_set(:@grouped_queries, nil)

  		@hand = create(:contact_instrument, name: :hand)
  		@mouth = create(:contact_instrument, name: :mouth)

  		@p1 = create(:possible_contact, contact_type: :penetrated, subject_instrument: @hand, object_instrument: @mouth)
  		@p2 = create(:possible_contact, contact_type: :touched, subject_instrument: @hand, object_instrument: @mouth)
  		@p3 = create(:possible_contact, contact_type: :touched, subject_instrument: @mouth, object_instrument: @hand)
  		@p4 = create(:possible_contact, contact_type: :sucked, subject_instrument: @mouth, object_instrument: @hand)
  	end

  	after :all do
  		PossibleContact.destroy_all
  		cleanup(@hand, @mouth)
  	end

  	describe 'hashed_for_partnership' do
  		it 'returns a dictionary with contact_types as keys and arrays of possible contacts as values' do
  			res = PossibleContact.hashed_for_partnership

  			expect(res).to have_key(:touched)
  			expect(res[:touched].length).to eq 2

  			expect(res).to have_key(:sucked)
  			expect(res[:sucked].length).to eq 1
  			expect(res[:sucked][0]).to eq @p4.as_document

  			expect(res).to have_key(:penetrated)
  		end
  	end
  end
end
