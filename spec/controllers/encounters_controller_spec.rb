require 'rails_helper'

RSpec.describe EncountersController, type: :controller do
	def make_user_and_encounters(num_encounters: 1, num_partners: 1)
		@user = create(:user_profile)
		num_partners.times do
			ship = @user.partnerships.create(partner: create(:profile))
			num_encounters.times { ship.encounters.create()}
		end
	end

	after :each do
		@user.destroy if @user
	end

	describe 'GET #index' do
		before :each do
			make_user_and_encounters(num_encounters: 2, num_partners: 2)
		end

		context 'with partnership id' do
			it 'shows the encounters for only that partnership' do
				ship = @user.partnerships.first
				get :index, params: {partnership_id: ship.id}, session: {user_id: @user.id}

				expect(assigns(:encounters)).to eq ship.encounters
				expect(assigns(:encounters)).to_not eq @user.encounters
			end
		end

		context 'without partnership id' do
			it 'shows the encounters for all partnerships the user has' do
				ship = @user.partnerships.first
				get :index, session: {user_id: @user.id}

				expect(assigns(:encounters)).to eq @user.encounters
			end
		end
	end

	describe 'GET #show' do
		context 'with valid encounter' do
			before do
				make_user_and_encounters
			end

			it 'shows the encounter' do
				ship = @user.partnerships.first
				enc = ship.encounters.first
				get :show, params: {partnership_id: ship.to_param, id: enc.to_param}, session: {user_id: @user.id}

				expect(assigns[:partnership]).to eq ship
				expect(assigns[:encounter]).to eq enc
			end
		end

		context 'without valid encounter' do
			before do
				make_user_and_encounters num_encounters: 0
			end

			it 'redirects back or to the encounters_path' do
				ship = @user.partnerships.first
				get :show, params: {partnership_id: ship.to_param, id: "whatever"}, session: {user_id: @user.id}

				expect(response).to redirect_to encounters_path
			end
		end
	end

	describe 'GET #new' do
		before :each do
			make_user_and_encounters num_encounters: 0
		end

		it 'makes a new encounter that is not nested in anything' do
			get :new, session: {user_id: @user.id}
			expect(assigns[:encounter].partnership).to be_nil
		end
	end
end
