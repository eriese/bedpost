require 'rails_helper'

RSpec.describe EncounterWhosController, type: :controller do
	describe 'POST #create' do
		before :each do
			@user = create(:user_profile)
			sign_in(@user)
		end

		after :each do
			cleanup(@user, @ship)
		end

		context 'with a valid partnership' do
			it 'redirects to the new encounter path for the partnership' do
				@ship = @user.partnerships.create(partner: dummy_user)
				post :create, params: {who: {partnership_id: @ship.id}}
				expect(response).to redirect_to new_partnership_encounter_path(@ship)
			end
		end

		context 'with invalid partnership' do
			it 'reloads the form with errors' do
				post :create, params: {who: {partnership_id: "whatever"}}
				expect(response).to redirect_to encounters_who_path
			end
		end

		context 'with the dummy id as partner id' do
			it 'redirects to new_partnership_path' do
				post :create, params: {who: {partnership_id: EncounterWhosController::DUMMY_ID}}
				expect(response).to redirect_to new_partnership_path
			end

			it 'saves :new_encounter on the session' do
				post :create, params: {who: {partnership_id: EncounterWhosController::DUMMY_ID}}
				expect(session[:new_encounter]).to be true
			end
		end
	end
end
