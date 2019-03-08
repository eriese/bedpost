require 'rails_helper'

RSpec.describe Contact::Instrument, type: :model do
  context 'HABTM' do
  	after :each do
  		cleanup(@inst1, @inst2)
  	end

  	describe '#can_penetrate and #can_be_penetrated_by' do
  		it 'keeps corresponding roles organized' do
	  		@inst1 = create(:contact_instrument, name: "hand")
	  		@inst2 = create(:contact_instrument, name: "genitals")

	  		@inst1.can_penetrate << @inst2
	  		expect(@inst1.reload.can_penetrate).to include(@inst2)
	  		expect(@inst2.can_be_penetrated_by).to include(@inst1)
	  	end
  	end

  	describe '#can_penetrate_self' do
  		it 'does not keep corresponding roles for self-contact' do
	  		@inst1 = create(:contact_instrument, name: "hand")
	  		@inst2 = create(:contact_instrument, name: "genitals")

	  		@inst1.can_penetrate_self << @inst2
	  		expect(@inst1.reload.can_penetrate_self).to include(@inst2)
	  		expect(@inst2.reload.can_be_penetrated_by_self).to_not include(@inst1)
	  	end
  	end

  	describe '#can_touch' do
  		it 'creates a mutual relationship with the same name' do
  			@inst1 = create(:contact_instrument, name: "hand")
	  		@inst2 = create(:contact_instrument, name: "genitals")

	  		@inst1.can_touch << @inst2
	  		expect(@inst1.reload.can_touch).to include(@inst2)
	  		expect(@inst2.can_touch).to include(@inst1)
	  	end

	  	it 'can connect to itself' do
	  		@inst1 = create(:contact_instrument, name: "hand")
	  		@inst1.can_touch << @inst1
	  		expect(@inst1.reload.can_touch).to include(@inst1)
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

  				expect(result).to eq I18n.t(inst_name)
  			end

  			it 'uses the given block to translate' do
  				inst_name = "hand"
  				inst = build(:contact_instrument, name: inst_name)

  				prc = Proc.new {|given| given*2}
  				result = inst.get_user_name_for(double(), &prc)

  				expect(result).to eq prc.call(inst_name)
  			end
  		end
  	end

  	describe '#show_for_user' do
  		it 'returns false if a user is not capable of a kind of contact' do
  			inst = build(:contact_instrument, conditions: {can_penetrate: [:can_penetrate?]})
  			user = double(can_penetrate?: false)

  			result = inst.show_for_user(user, :can_penetrate)
  			expect(result).to be false
  		end

  		it 'returns false if a user does not have the instrument' do
  			inst = build(:contact_instrument, conditions: {all: [:can_penetrate?]})
  			user = double(can_penetrate?: false)

  			result = inst.show_for_user(user, :can_penetrate)
  			expect(result).to be false
  		end

  		it 'gets the conditions for the normal version if there are no special conditions for _self' do
  			inst = build(:contact_instrument, conditions: {can_penetrate: [:can_penetrate?]})
  			user = double(can_penetrate?: false)

  			result = inst.show_for_user(user, :can_penetrate_self)
  			expect(result).to be false
  		end

  		it 'can check multiple conditions in any order' do
  			inst = build(:contact_instrument, conditions: {can_penetrate: [:can_penetrate?, :has_internal?]})
  			user = double(can_penetrate?: true, has_internal?: false)
  			user2 = double(can_penetrate?: false, has_internal?: true)
  			user3 = double(can_penetrate?: true, has_internal?: true)

  			result1 = inst.show_for_user(user, :can_penetrate)
  			expect(result1).to be false
  			result2 = inst.show_for_user(user2, :can_penetrate)
  			expect(result2).to be false
  			result3 = inst.show_for_user(user3, :can_penetrate)
  			expect(result3).to be true
  		end

  		it 'gracefully handles empty conditions' do
  			inst = build(:contact_instrument)
  			expect(inst.show_for_user(double(), :can_penetrate)).to be true

  			inst2 = build(:contact_instrument, conditions: {})
  			expect(inst2.show_for_user(double(), :can_penetrate)).to be true
  		end
  	end
  end
end