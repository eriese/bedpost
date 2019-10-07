require 'rails_helper'

RSpec.describe UserProfiles::RegistrationsController, type: :controller do
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user_profile]
	end

	describe 'POST #create' do
		context 'with valid parameters' do
			def get_valid_params
				{user_profile: attributes_for(:user_profile)}
			end

			def get_new_prof(params)
				UserProfile.find_by(email: params[:user_profile][:email])
			end

			after :each do
				cleanup @prof
			end

			it "creates a new UserProfile" do
				valid_params = get_valid_params

				expect{post :create, params: valid_params}.to change(UserProfile, :count).by(1)
				@prof = get_new_prof(valid_params)
				expect(@prof).to_not be_nil
			end

			it "saves the submitted name, email, and password" do
				valid_params = {user_profile: attributes_for(:user_profile)}
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)
				expect(@prof.pronoun).to be_nil
				expect(@prof.name).to eq valid_params[:user_profile][:name]
				expect(@prof.email).to eq valid_params[:user_profile][:email]
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

				expect(response).to redirect_to edit_user_profile_registration_path
			end
		end
	end
end
