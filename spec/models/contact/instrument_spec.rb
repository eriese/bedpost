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
  context 'HABTM' do
  	after :each do
  		cleanup(@inst1, @inst2, @possible)
  	end

  	describe '#can_penetrate and #can_be_penetrated_by' do
  		it 'keeps corresponding roles organized' do
	  		@inst1 = create(:contact_instrument, name: :hand)
	  		@inst2 = create(:contact_instrument, name: :genitals)
        @possible = create(:possible_contact, contact_type: :penetrated, subject_instrument: @inst1, object_instrument: @inst2)

	  		expect(@inst1.reload.can_penetrate).to include(@inst2.id)
	  		expect(@inst2.can_be_penetrated_by).to include(@inst1.id)
	  	end
  	end

  	# describe '#can_penetrate_self' do
  	# 	it 'keeps corresponding roles for self-contact' do
	  # 		expect(Contact::Instrument.relations[:can_penetrate_self].forced_nil_inverse?).to be true
	  # 	end
  	# end

  	describe '#can_touch' do
  		it 'creates a mutual relationship with the same name' do
  			@inst1 = create(:contact_instrument, name: "hand")
	  		@inst2 = create(:contact_instrument, name: "genitals")
        @possible = create(:possible_contact, contact_type: :touched, subject_instrument: @inst1, object_instrument: @inst2)

	  		expect(@inst1.reload.can_touch).to include(@inst2.id)
	  		expect(@inst2.can_touch).to include(@inst1.id)
	  	end

	  	it 'can connect to itself' do
	  		@inst1 = create(:contact_instrument, name: "hand")
        @possible = create(:possible_contact, contact_type: :touched, subject_instrument: @inst1, object_instrument: @inst1)
	  		# @inst1.can_touch << @inst1
	  		expect(@inst1.reload.can_touch).to include(@inst1.id)
        expect(@inst1.can_touch.size).to eq 1
	  	end
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

  	pending '#show_for_user' do
  		it 'returns false if a user is not capable of a kind of contact' do
  			inst = build(:contact_instrument, conditions: {can_penetrate: [:can_penetrate?]})
  			user = double(can_penetrate?: false)

  			result = inst.show_for_user(user, Contact::ContactType::PENETRATED)
  			expect(result).to be false
  		end

  		it 'returns false if a user does not have the instrument' do
  			inst = build(:contact_instrument, conditions: {all: [:can_penetrate?]})
  			user = double(can_penetrate?: false)

  			result = inst.show_for_user(user, Contact::ContactType::PENETRATED)
  			expect(result).to be false
  		end

  		it 'gets the conditions for the normal version if there are no special conditions for _self' do
  			inst = build(:contact_instrument, conditions: {can_penetrate: [:can_penetrate?]})
  			user = double(can_penetrate?: false)

  			result = inst.show_for_user(user, Contact::ContactType::PENETRATED_self)
  			expect(result).to be false
  		end

  		it 'can check multiple conditions in any order' do
  			inst = build(:contact_instrument, conditions: {can_penetrate: [:can_penetrate?, :has_internal?]})
  			user = double(can_penetrate?: true, has_internal?: false)
  			user2 = double(can_penetrate?: false, has_internal?: true)
  			user3 = double(can_penetrate?: true, has_internal?: true)

  			result1 = inst.show_for_user(user, Contact::ContactType::PENETRATED)
  			expect(result1).to be false
  			result2 = inst.show_for_user(user2, Contact::ContactType::PENETRATED)
  			expect(result2).to be false
  			result3 = inst.show_for_user(user3, Contact::ContactType::PENETRATED)
  			expect(result3).to be true
  		end

  		it 'gracefully handles empty conditions' do
  			inst = build(:contact_instrument)
  			expect(inst.show_for_user(double(), Contact::ContactType::PENETRATED)).to be true

  			inst2 = build(:contact_instrument, conditions: {})
  			expect(inst2.show_for_user(double(), Contact::ContactType::PENETRATED)).to be true
  		end
  	end
  end

  context 'class methods' do
    describe '.by_name' do
      before :all do
        @names = ["hand", "mouth", "toys"]
        @names.each {|n| create(:contact_instrument, name: n)}
      end

      after :all do
        Contact::Instrument.delete_all
      end

      it 'gets a hash of instruments with names as keys' do
        result = Contact::Instrument.by_name
        expect(result).to be_a(Hash)
        @names.each {|n| expect(result).to have_key(n)}
      end

      it 'gets a hash that gives access for strings or symbols' do
        names = Contact::Instrument.by_name
        expect(names[:hand]).to eq names["hand"]
      end

      it 'caches' do
        names = Contact::Instrument.by_name
        allow(Contact::Instrument).to receive(:all){[]}
        Contact::Instrument.by_name
        expect(Contact::Instrument).to_not have_received(:all)
      end
    end
  end
end
