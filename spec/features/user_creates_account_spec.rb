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

		def register_user
			visit new_user_profile_registration_path
			@user_params = attributes_for(:user_profile)
			fill_in 'Name*', with: @user_params[:name]
			fill_in 'Email*', with: @user_params[:email]
			fill_in 'Password*', with: @user_params[:password]
			fill_in 'Re-type your password*', with: @user_params[:password]
			click_button "signup-submit"
		end

		def fill_in_profile
			choose('user_profile_opt_in_true')
			select(Pronoun.find(@user_params[:pronoun_id]).display, from: 'user_profile_pronoun_id')
			fill_in 'user_profile_anus_name', with: @user_params[:anus_name]
			fill_in 'user_profile_external_name', with: @user_params[:external_name]
			choose("user_profile_can_penetrate_#{@user_params[:can_penetrate]}")
			fill_in 'user_profile_internal_name', with: @user_params[:internal_name]
			click_button 'Save'
		end

		scenario "The user is redirected to the edit_user_profile_registration page" do
			register_user
			expect(page).to have_current_path(edit_user_profile_registration_path)
		end

		scenario 'The edit user profile page has limited fields' do
			register_user

			expect(page).to have_no_field('user_profile_name')
			expect(page).to have_no_field('user_profile_uid')
			expect(page).to have_no_content(I18n.t('application.edit.security_settings.title'))
			expect(page).to have_no_content(I18n.t('application.edit.delete_profile.title'))

			fill_in_profile

			user = UserProfile.find_by(email: @user_params[:email])
			expect(user).to be_set_up
		end

		scenario 'After editing the profile, the user is taken to the first_time page' do
			register_user
			fill_in_profile

			expect(page).to have_current_path(first_time_index_path)
		end
	end
end
