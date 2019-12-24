require 'rails_helper'

feature 'User confirms email', :slow do
	after do
		cleanup @user
	end

	scenario 'The user is logged in and sees a flash message saying their email was successfully confirmed' do
		register_user
		@user = UserProfile.last
		allow(Terms).to receive(:newest) { double('Terms', updated_at: DateTime.now - 1.day)}
		@user.update(@user_params)

		visit user_profile_confirmation_path(confirmation_token: @user.confirmation_token)
		expect(page).to have_content(I18n.t('devise.confirmations.confirmed'))
		expect(page).not_to have_content(I18n.t('devise.sessions.signed_in'))
	end
end
