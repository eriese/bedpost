require 'rails_helper'

RSpec.describe Partnership, type: :model do
	describe '#partner' do
		after :each do
			@user.destroy if @user && @user.persisted?
			@user2.destroy if @user2 && @user2.persisted?
			@partner.destroy if @partner && @partner.persisted?
		end

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
	  	ship2 = Partnership.new(partner_id: @partner.id)
	  	@user.partnerships << ship2
	  	expect(@user).to_not be_valid
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
end
