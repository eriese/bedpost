require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do
	describe "GET #new" do
		it "redirects to user profile page if user is already logged in" do
			get :new, session: dummy_user_session
			expect(response).to redirect_to user_profile_path
		end
	end

	describe "POST #create" do
		context "with valid params" do
			def get_valid_params
				{user_profile: attributes_for(:user_profile)}
			end

			def get_new_prof(params)
				UserProfile.find_by(email: params[:user_profile][:email])
			end

			before :each do
				@prof = nil
			end

			after :each do
				@prof.destroy unless @prof.nil?
			end

			it "creates a new UserProfile" do
				valid_params = get_valid_params

				expect{post :create, params: valid_params}.to change(UserProfile, :count).by(1)
				@prof = get_new_prof(valid_params)
				expect(@prof).to_not be_nil
			end

			it "only saves the submitted name, email, and password" do
				valid_params = {user_profile: attributes_for(:user_profile)}
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)
				expect(@prof.pronoun).to be_nil
			end

			it "signs the user in" do
				valid_params = get_valid_params
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)

				expect(controller.current_user).to eq @prof
			end

			it "redirects the user to the edit profile page to submit more information" do
				valid_params = get_valid_params
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)

				expect(response).to redirect_to edit_user_profile_path
			end
		end

		context "with invalid params" do
			it "reloads the page" do
				post :create, params: {user_profile: {name: ""}}
				expect(response).to redirect_to signup_path
			end

			it "puts the error messages in the flash[:submission_error] hash" do
				post :create, params: {user_profile: attributes_for(:user_profile, name: "")}
				expect(flash[:submission_error]).to have_key(:name)
			end

			it "puts the user's previous attempt into flash [:profile_attempt]" do
				params = {user_profile: {name: "Alice", password: "pass"}}
				post :create, params: params

				flash_hash = flash[:profile_attempt].to_hash
				flash_hash.transform_keys! {|k| k.intern }
				expect(flash_hash).to eq params[:user_profile]
			end
		end
	end
end
