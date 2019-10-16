require 'rails_helper'

feature "User creates account", :slow do
	context "with invalid fields" do
		before :each do
			visit new_user_profile_registration_path
			@user_params = attributes_for(:user_profile)
			fill_in 'Email*', with: @user_params[:email]
			fill_in 'Password*', with: @user_params[:password]
			click_button "signup-submit"
		end

		scenario "The user sees their previously entered values" do
			email_val = find_field("Email*").value
			expect(email_val).to eq @user_params[:email]
		end

		scenario "The user's previously entered password is not present" do
			pass_val = find_field("Password*").value
			expect(pass_val).to be_nil
		end
	end

	context "with valid fields" do
		after :each do
			user = UserProfile.find_by(email: @user_params[:email])
			cleanup user
		end

		scenario "The user is redirected to the edit_user_profile_registration page" do
			visit new_user_profile_registration_path
			@user_params = attributes_for(:user_profile)
			fill_in 'Name*', with: @user_params[:name]
			fill_in 'Email*', with: @user_params[:email]
			fill_in 'Password*', with: @user_params[:password]
			fill_in 'Re-type your password*', with: @user_params[:password]
			click_button "signup-submit"

			expect(page).to have_current_path(edit_user_profile_registration_path)
		end
	end
end
