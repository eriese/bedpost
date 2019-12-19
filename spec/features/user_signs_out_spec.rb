require 'rails_helper'

feature 'User signs out', :slow do
	after do
		cleanup @user
	end

	scenario 'The user is redirected to the login page with a signout success message' do
		allow(Terms).to receive(:newest) { double('Terms', updated_at: DateTime.now - 1.day)}
		@user = create(:user_profile, first_time: false, terms: {tou: DateTime.now, privacy: DateTime.now})

		sign_in @user
		visit root_path
		click_on 'Log out'
		expect(page).to have_current_path new_user_profile_session_path
		expect(page).to have_content 'Signed out successfully.'
		expect(page).not_to have_content 'You need to sign in or sign up before continuing.'
	end
end
