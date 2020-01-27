require 'rails_helper'

feature 'User signs in/out', :slow do
	after do
		cleanup @user
	end

	scenario 'The user sees a successful login message after logging in' do
		allow(Terms).to receive(:newest) { double('Terms', updated_at: DateTime.now - 1.day)}
		login_new_user
		expect(page).to have_content(I18n.t('devise.sessions.signed_in'))
	end

	scenario 'The user is redirected to the login page with a signout success message after logging out' do
		allow(Terms).to receive(:newest) { double('Terms', updated_at: DateTime.now - 1.day)}
		login_new_user

		click_on 'Log out'
		expect(page).to have_current_path new_user_profile_session_path
		expect(page).to have_content 'Signed out successfully.'
		expect(page).not_to have_content 'You need to sign in or sign up before continuing.'
	end
end
