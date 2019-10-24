require 'rails_helper'

RSpec.describe Partnership, type: :model do
	def create_ship(partner_alias)
		@user = create(:user_profile)
		@partner = create(partner_alias)
		@ship = @user.partnerships.new(partner: @partner)
	end

	after :each do
		cleanup(@user, @user2, @partner)
	end

	describe '#encounters' do
		before :all do
			@user = create(:user_profile)
			@partner = create(:profile)
			@obj = @user.partnerships.create(partner: @partner)
		end

		it_should_behave_like 'an object that dirty-tracks its embedded relations', Partnership, true

		it 'responds to encounters' do
			expect(@obj).to respond_to :encounters
		end
	end

	describe '#partner' do
	  it 'can accept a profile as a partner' do
	  	create_ship(:profile)

	  	expect(@ship).to_not be_nil
	  	expect(@user.partnerships.length).to eq 1
	  	expect(@ship.partner_id).to eq @partner.id
	  	expect(@ship.partner).to eq @partner
	  end

	  it 'can accept a user_profile as a partner' do
	  	create_ship(:user_profile)

	  	expect(@ship).to_not be_nil
	  	expect(@user.partnerships.length).to eq 1
	  	expect(@ship.partner_id).to eq @partner.id
	  	expect(@ship.partner).to eq @partner
	  end

	  it 'works with saving and everything' do
	  	create_ship(:user_profile)
	  	@user.save

	  	#get everything fresh
	  	saved_user = UserProfile.find(@user.id)
	  	expect(saved_user.partnerships.length).to eq 1
	  	saved_ship = saved_user.partnerships[0]
	  	expect(saved_ship.partner_id).to eq @partner.id
	  	expect(saved_ship.partner).to eq @partner
	  end

	  it 'validates the uniqueness of the partner' do
	  	create_ship(:user_profile)
	  	@user.save

	  	expect(@user).to be_valid
	  	ship2 = @user.partnerships.new(partner_id: @partner.id)
	  	expect(ship2).to_not be_valid
	  end

	  it 'only validates uniqueness of partner within the scope of the user' do
	  	create_ship(:user_profile)
	  	@user.save

	  	@user2 = create(:user_profile)
	  	expect(@user2).to be_valid
	  	@user2.partnerships.new(partner: @partner)
	  	expect(@user2).to be_valid
	  end

	  it 'does not allow a user to partner with themself' do
	  	@user = create(:user_profile)
	  	expect(@user).to be_valid
	  	@user.partnerships.new(partner: @user)
	  	expect(@user).to_not be_valid
	  end
	end

	describe '#uid' do
		context 'setter' do
			it 'sets the partner if given a valid uid' do
				@user = create(:user_profile)
				@partner = create(:user_profile)

				ship = @user.partnerships.new
				expect(ship.partner_id).to be_nil

				ship.uid = @partner.uid
				expect(ship.partner_id).to eq @partner.id
				expect(ship.uid).to eq @partner.uid
			end

			it 'sets the uid but not the partner if given an invalid uid' do
				@user = create(:user_profile)
				ship = @user.partnerships.new
				ship.uid = "invalid"

				expect(ship.partner_id).to be_nil
				expect(ship.uid).to eq "invalid"
			end

			it 'sets the uid but not the partner if given the uid of the user' do
				@user = create(:user_profile)
				ship = @user.partnerships.new
				ship.uid = @user.uid

				expect(ship.partner_id).to be_nil
				expect(ship.uid).to eq @user.uid
			end

			it 'does not overwrite a valid partner with an invalid uid' do
				@user = create(:user_profile)
				@partner = create(:user_profile)

				ship = @user.partnerships.new(partner: @partner)
				ship.uid = "invalid"

				expect(ship.partner_id).to eq @partner.id
				expect(ship.uid).to eq @partner.uid
			end

			it 'overwrites a valid partner with another valid uid' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				@user2 = create(:user_profile)

				ship = @user.partnerships.new(partner: @partner)
				ship.uid = @user2.uid

				expect(ship.partner_id).to eq @user2.id
				expect(ship.uid).to eq @user2.uid
			end

			it 'works with update' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				@user2 = create(:user_profile)

				ship = @user.partnerships.create(partner: @partner)
				expect(ship.update_attributes(uid: @user2.uid)).to be true

				ship.reload

				expect(ship.partner_id).to eq @user2.id
				expect(ship.uid).to eq @user2.uid
			end
		end

		describe 'getter' do
			it 'gets the uid that was set with an invalid input' do
				@user = create(:user_profile)
				ship = @user.partnerships.new(uid: "invalid")

				expect(ship.uid).to eq "invalid"
			end

			it 'does not check the partner if the setter has been invoked' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				ship = @user.partnerships.new(uid: @partner.uid)

				allow(ship).to receive(:partner).and_call_original
				expect(ship.uid).to eq @partner.uid
				expect(ship).to_not have_received(:partner)
			end

			it 'checks the partner if the setter has not been invoked' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				ship = @user.partnerships.new(partner_id: @partner.id)

				allow(ship).to receive(:partner).and_call_original
				expect(ship.uid).to eq @partner.uid
				expect(ship).to have_received(:partner)
			end
		end

		describe 'validation' do
			it 'gives an exclusion error with a taken message if asked to set the uid to one belonging to an existing partner' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				ship = @user.partnerships.new(partner_id: @partner.id)
				@user.save

				ship2 = @user.partnerships.new(uid: @partner.uid)
				expect(ship2).to_not be_valid
				expect(ship2).to have_validation_error_for :uid, :exclusion
				expect(ship2.errors.messages[:uid]).to include(I18n.t("mongoid.errors.models.partnership.attributes.uid.taken", default: [:"mongoid.errors.messages.taken"]))
			end

			it 'gives a bad_key error if the uid does not correspond with the uid of a user in the database' do
				@user = create(:user_profile)
				ship = @user.partnerships.new(uid: "invalid")

				expect(ship).to_not be_valid
				expect(ship).to have_validation_error_for :uid, :bad_key
			end

			it 'gives an self_key error if the given uid belongs to the user' do
				@user = create(:user_profile)
				ship = @user.partnerships.new(uid: @user.uid)

				expect(ship).to_not be_valid
				expect(ship).to have_validation_error_for :uid, :self_key
			end
		end
	end

	describe '#last_took_place' do
		context 'with encounters' do
			after :each do
				cleanup(@possible, @hand)
			end
			it 'returns the date of the last encounter' do
				create_ship(:profile)
				@hand = create(:contact_instrument, name: :hand)
				@possible = create(:possible_contact, contact_type: :touched, subject_instrument: @hand, object_instrument: @hand)
				enc = create(:encounter, partnership: @ship, contacts: [build(:encounter_contact, possible_contact: @possible)])
				expect(@ship.last_took_place).to eq enc.took_place
			end
		end

		context 'without encounters' do
			it 'returns the date from today if given nothing' do
				create_ship(:profile)
				expect(@ship.last_took_place).to eq Date.today
			end

			it 'returns the given value' do
				create_ship(:profile)
				given = "today"
				expect(@ship.last_took_place(given)).to eq given
			end
		end
	end

	describe '#display' do
		it 'shows #{partner.name} #{nickname}' do
			create_ship(:profile)
			expect(@ship.display).to eq "#{@partner.name} #{@ship.nickname}"
		end
	end

	describe '#risk_mitigator' do
		it 'returns a number between 0 and 4' do
			ship1 = build_stubbed(:partnership, familiarity: 1, exclusivity: 1, communication: 1, trust: 1, prior_discussion: 1)
			expect(ship1.risk_mitigator).to eq 0

			ship2 = build_stubbed(:partnership, familiarity: 10, exclusivity: 10, communication: 10, trust: 10, prior_discussion: 10)
			expect(ship2.risk_mitigator).to eq 4

			ship3 = build_stubbed(:partnership, familiarity: 5, exclusivity: 5, communication: 5, trust: 5, prior_discussion: 5)
			expect(ship3.risk_mitigator).to eq 2
		end
	end

	describe '#any_level_changed?' do
		it 'checks changes on the partnership level fields' do
			create_ship(:profile)
			@ship.exclusivity += 1
			expect(@ship.any_level_changed?).to be true
		end

		it 'is called during after_save' do
			create_ship(:profile)
			allow(@ship).to receive(:any_level_changed?).and_call_original

			@ship.update(exclusivity: @ship.exclusivity + 1)
			expect(@ship).to have_received(:any_level_changed?)
		end

		it 'is used to clear the risk_mitigator calculation on save' do
			create_ship(:profile)
			@ship.risk_mitigator
			original = @ship.instance_variable_get(:@risk_mitigator)
			@ship.update(exclusivity: @ship.exclusivity + 1)
			changed = @ship.instance_variable_get(:@risk_mitigator)
			expect(changed).to be_nil
			expect(changed).to_not be original
		end
	end

	describe '#add_to_partner' do
		it 'adds the user to the partner as a foreign key in partnered_to' do
			@user = create(:user_profile)
			@partner = create(:profile)

			ship = @user.partnerships.new(partner: @partner)
			ship.send :add_to_partner

			@partner.reload
			expect(@partner.partnered_to).to include(@user)
		end

		it 'does not call #remove_from_partner to remove itself from the previous partner if it is new' do
			@user = create(:user_profile)
			@partner = create(:profile)

			ship = @user.partnerships.new(partner: @partner)
			allow(ship).to receive(:remove_from_partner)
			ship.send :add_to_partner

			expect(ship).to_not have_received(:remove_from_partner)
		end

		it 'calls #remove_from_partner to remove itself from the previous partner' do
			@user = create(:user_profile)
			@partner = create(:profile)
			@user2 = create(:profile)

			ship = @user.partnerships.create(partner: @partner)
			allow(ship).to receive(:remove_from_partner).and_call_original
			ship.partner = @user2
			ship.send :add_to_partner

			expect(ship).to have_received(:remove_from_partner).with(@partner.id)
		end
	end

	describe '#remove_from_partner' do
		it 'removes the user from the given partner as a foreign key in partnered_to' do
			allow_any_instance_of(Profile).to receive(:delete_if_empty)
			@user = create(:user_profile)
			@partner = create(:profile)

			ship = @user.partnerships.new(partner: @partner)
			@partner.add_partnered_to(@user)
			expect(@partner.partnered_to).to include(@user)

			ship.send :remove_from_partner
			@partner.reload
			expect(@partner.partnered_to).to_not include(@user)
		end
	end

	describe 'after_save' do
		it 'adds its user to the partner as a foreign key in #partnered_to' do
			@user = create(:user_profile)
			@partner = create(:profile)

			ship = @user.partnerships.new(partner: @partner)
			allow(ship).to receive(:add_to_partner).and_call_original
			ship.save

			expect(ship).to have_received(:add_to_partner)
			@partner.reload
			expect(@partner.partnered_to).to include(@user)
		end

		it 'removes its user from the previous partner' do
			allow_any_instance_of(Profile).to receive(:delete_if_empty)
			@user = create(:user_profile)
			@partner = create(:profile)
			@user2 = create(:profile)

			ship = @user.partnerships.create(partner: @partner)
			allow(ship).to receive(:remove_from_partner).and_call_original
			ship.update(partner: @user2)

			expect(ship).to have_received(:remove_from_partner).with(@partner.id)

			@partner.reload
			expect(@partner.partnered_to).to_not include(@user)
		end

		it 'works every time' do
			allow_any_instance_of(Profile).to receive(:delete_if_empty)
			@user = create(:user_profile)
			@partner = create(:profile)
			@user2 = create(:profile)

			ship = @user.partnerships.create(partner: @user2)

			#test switching partners 4 times
			partners = [@partner, @user2]
			4.times do
				ship.partner = partners[0]
				ship.save

				partners.each{ |p| p.reload}
				expect(partners[0].partnered_to.find(@user)).to eq @user
				expect(partners[1].partnered_to).to_not include(@user)

				partners.reverse!
			end
		end

		it 'causes a cascading call to delete an empty partner' do
			@user = create(:user_profile)
			@partner = create(:profile)
			@user2 = create(:profile)

			ship = @user.partnerships.create(partner: @partner)
			allow(@partner).to receive(:delete_if_empty).and_call_original
			# don't let the partnership get a fresh reference to partner or it'll break the spy
			allow(Profile).to receive(:find).and_return(@partner)
			ship.partner = @user2
			ship.save

			expect(@partner).to have_received(:delete_if_empty)
			expect {@partner.reload}.to raise_error(Mongoid::Errors::DocumentNotFound)
		end
	end

	describe 'before_destroy' do
		it 'removes its user from its partner' do
			allow_any_instance_of(Profile).to receive(:delete_if_empty)
			@user = create(:user_profile)
			@partner = create(:profile)

			ship = @user.partnerships.create(partner: @partner)

			@partner.reload
			expect(@partner.partnered_to).to include(@user)

			ship.destroy
			@partner.reload
			expect(@partner.partnered_to).to_not include(@user)
		end

		it 'causes a cascading call to delete an empty partner' do
			@user = create(:user_profile)
			@partner = create(:profile)

			ship = @user.partnerships.create(partner: @partner)
			allow(@partner).to receive(:delete_if_empty).and_call_original
			# don't let the partnership get a fresh reference to partner or it'll break the spy
			allow(Profile).to receive(:find).and_return(@partner)
			ship.destroy

			expect(@partner).to have_received(:delete_if_empty)
			expect {@partner.reload}.to raise_error(Mongoid::Errors::DocumentNotFound)
		end
	end
end
