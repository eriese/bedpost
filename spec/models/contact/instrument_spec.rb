require 'rails_helper'

RSpec.describe Contact::Instrument, type: :model do
  context 'custom id' do
    after :each do
      cleanup(@inst)
    end

    it 'uses the name as the id' do
      @inst = Contact::Instrument.new(name: :hand);
      @inst.save
      expect(@inst.id).to eq @inst.name
    end
  end

  context 'methods' do
  	describe '#get_user_name_for' do
  		context 'with a user_override' do
  			it 'returns the user-inputted name for the instrument' do
	  			user = double({external_name: "ext"})
	  			inst = build(:contact_instrument, name: "external_genitals", user_override: :external_name)

	  			t_block = I18n.method(:t)
	  			result = inst.get_user_name_for(user)
	  			expect(result).to eq user.external_name
	  		end
  		end

  		context 'without user_override' do
  			it 'defaults to using regular I18n' do
  				inst_name = "hand"
  				inst = build(:contact_instrument, name: inst_name)
  				result = inst.get_user_name_for(double())

  				expect(result).to eq I18n.t(inst_name, scope: "contact.instrument")
  			end

  			it 'uses the given block to translate' do
  				inst_name = "hand"
  				inst = build(:contact_instrument, name: inst_name)

  				prc = Proc.new {|given| given.to_s*2}
  				result = inst.get_user_name_for(double(), &prc)

  				expect(result).to eq prc.call(inst_name)
  			end
  		end
  	end
  end

  context 'class methods' do
    describe '#hashed_for_partnership' do
      it 'caches based on user and partner id and update times' do
        user = build_stubbed(:user_profile)
        partner = build_stubbed(:profile)
        allow(Contact::Instrument).to receive(:as_map).and_call_original
        Contact::Instrument.hashed_for_partnership(user, partner)
        expect(Contact::Instrument).to have_received(:as_map).once

        Contact::Instrument.hashed_for_partnership(user, partner)
        expect(Contact::Instrument).to have_received(:as_map).once

        user.updated_at += 1.day
        Contact::Instrument.hashed_for_partnership(user, partner)
        expect(Contact::Instrument).to have_received(:as_map).twice
      end

      it 'adds the overrides for the partner and user to the serialized hash' do
        user = build_stubbed(:user_profile)
        partner = build_stubbed(:profile)
        inst = build_stubbed(:contact_instrument, name: :external_genitals, user_override: :external_name)

        allow(Contact::Instrument).to receive(:as_map) {
          Hash[inst.id, inst]
        }

        result = Contact::Instrument.hashed_for_partnership(user, partner)
        expect(result[inst.id]).to be_a(Hash)
        expect(result[inst.id][:user_name]).to eq user.external_name
        expect(result[inst.id][:partner_name]).to eq partner.external_name
      end
    end
  end
end
