require 'rails_helper'

RSpec.describe ResetsController, type: :controller do
	describe 'POST #create' do
		# pending 'user submits an email address that is not in system'

		context 'user submits an email address that is in the system' do
			after :each do
				UserToken.all.destroy
			end

			it 'creates a reset token for the user' do
				post :create, params: {reset: {email: dummy_user.email}}
				token_query = UserToken.where(user_profile_id: dummy_user.id, token_type: "reset")
				expect(token_query.count).to eq 1
			end
		end
	end

	describe 'GET #edit' do
		before :each do
			@token = UserToken.reset_token!(dummy_user.id)
		end

		after :each do
			@token.destroy
		end

		context 'user comes from app-generated link with valid token' do
			it 'it is successful' do
				get :edit, params: {e: dummy_user.email, t: @token.id}
				expect(response).to be_successful
			end
		end

		context 'user tries to reset with incomplete or incorrect params' do
			def get_wrong(params)
				get :edit, params: params
				expect(response).to redirect_to login_path
			end

			it 'redirects to login page with a missing email address' do
				get_wrong({t: @token.id})
			end

			it 'redirects to login page with a missing token' do
				get_wrong({e: dummy_user.email})
			end

			it 'redirects to login page if the token does not belong to the user' do
				get_wrong({t: @token.id, e: build_stubbed(:user_profile).email})
			end
		end
	end

	describe 'PUT #update' do
		before :each do
			@user = create(:user_profile)
			@token = UserToken.reset_token!(@user.id)
			@pass = "new-pass"
		end

		after :each do
			@token.destroy
			@user.destroy
		end

		context 'token is valid' do
			before :each do
				put :update, params: {reset_token: @token.id, user_profile: {id: @user.id, password: @pass}}
			end

			it 'saves the password submitted by the user' do
				@user.reload
				expect(@user.authenticate(@pass)).to be @user
			end

			it 'logs the user in' do
				expect(controller.current_user).to eq @user
			end

			it 'redirects to the user profile page' do
				expect(response).to redirect_to user_profile_path
			end
		end
	end
end
