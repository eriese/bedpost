require 'rails_helper'

RSpec.describe ResetsController, type: :controller do
	# describe 'POST #create' do
	# 	before :each do
	# 		allow(SendPasswordResetJob).to receive(:perform_later) {nil}
	# 	end

	# 	context 'user submits an email address that is not in system' do
	# 		it 'refreshes the page' do
	# 			post :create, params: {reset: {email: "wrong_email"}}
	# 			expect(response).to redirect_to retrieve_path
	# 		end

	# 		it 'send a submission error on the email' do
	# 			post :create, params: {reset: {email: "wrong_email"}}
	# 			expect(flash[:submission_error]).to_not be_nil
	# 			expect(flash[:submission_error][:email]).to eq I18n.t("reset.errors.email.not_found_html", {url: signup_path})
	# 		end
	# 	end

	# 	context 'user submits an email address that is in the system' do
	# 		it 'triggers a job to creates a reset token for the user and email it to them' do

	# 			post :create, params: {reset: {email: dummy_user.email}}
	# 			expect(SendPasswordResetJob).to have_received(:perform_later).with(dummy_user)
	# 		end
	# 	end
	# end

	# describe 'GET #edit' do
	# 	before :each do
	# 		@token = UserToken.reset_token!(dummy_user.id)
	# 	end

	# 	after :each do
	# 		@token.destroy
	# 	end

	# 	context 'user comes from app-generated link with valid token' do
	# 		it 'it is successful' do
	# 			get :edit, params: {e: dummy_user.email, t: @token.id}
	# 			expect(response).to be_successful
	# 		end
	# 	end

	# 	context 'user tries to reset with incomplete or incorrect params' do
	# 		def get_wrong(params)
	# 			get :edit, params: params
	# 			expect(response).to redirect_to login_path
	# 		end

	# 		it 'redirects to login page with a missing email address' do
	# 			get_wrong({t: @token.id})
	# 		end

	# 		it 'redirects to login page with a missing token' do
	# 			get_wrong({e: dummy_user.email})
	# 		end

	# 		it 'redirects to login page if the token does not belong to the user' do
	# 			get_wrong({t: @token.id, e: build_stubbed(:user_profile).email})
	# 		end
	# 	end
	# end

	# describe 'PUT #update' do
	# 	before :each do
	# 		@user = create(:user_profile)
	# 		@token = UserToken.reset_token!(@user.id)
	# 		@pass = "new-pass"
	# 	end

	# 	after :each do
	# 		@token.destroy
	# 		@user.destroy
	# 	end

	# 	context 'token is valid' do
	# 		before :each do
	# 			put :update, params: {reset_token: @token.id, user_profile: {id: @user.id, password: @pass}}
	# 		end

	# 		it 'saves the password submitted by the user' do
	# 			@user.reload
	# 			expect(@user.authenticate(@pass)).to be @user
	# 		end

	# 		it 'logs the user in' do
	# 			expect(controller.current_user).to eq @user
	# 		end

	# 		it 'redirects to the user profile page' do
	# 			expect(response).to redirect_to user_profile_path
	# 		end
	# 	end
	# end
end
