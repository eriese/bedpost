require 'rails_helper'

feature 'User adds uid to existing partnership', :slow do
	after do
		cleanup @user, @partner1, @partner2
	end

	scenario 'the user is no longer given the option to edit the partner profile' do
		allow(Terms).to receive(:newest) { double('Terms', updated_at: DateTime.now - 1.day)}
		@user = create(:user_profile, first_time: false, terms: {tou: DateTime.now, privacy: DateTime.now})
		@partner1 = create(:profile, name: 'Annie')
		@partner2 = create(:user_profile, name: 'Doug')
		ship = build(:partnership, partner: @partner1)
		@user.partnerships << ship

		sign_in @user

		visit edit_partnership_path(ship)
		edit_label = I18n.t('partnerships.edit.edit_partner_uid')
		click_on edit_label
		fill_in 'partnership_uid', with: @partner2.uid

		find('input[type=submit][name=commit]').click

		expect(page).to have_content @partner2.name
		expect(page).not_to have_content @partner1.name
		expect(page).not_to have_link edit_label
	end
end
