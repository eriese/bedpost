require 'rails_helper'

RSpec.describe Partnership, type: :model do
	after :each do
		@user.destroy if @user && @user.persisted?
		@user2.destroy if @user2 && @user2.persisted?
		@partner.destroy if @partner && @partner.persisted?
	end

	describe '#partner' do
		def create_ship(partner_alias)
			@user = create(:user_profile)
	  	@partner = create(partner_alias)
	  	@ship = @user.partnerships.new(partner: @partner)
  	end

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
end
