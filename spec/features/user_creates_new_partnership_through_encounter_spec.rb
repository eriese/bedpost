require 'rails_helper'

feature "User creates new partnership through encounter", :slow do

	before :each do
		Terms.create(terms: 'some terms', type: :tou)
		Terms.create(terms: 'some other terms', type: :privacy)
		login_new_user
		accept_date = Date.today + 1
		@user.update_attributes({first_time: false, terms: {tou: accept_date, privacy: accept_date}})
	end

	after :each do
		cleanup(@user, @partner)
		Terms.destroy_all
	end

	context "with uid from an existing user" do
		scenario "The user ends up on the encounter page with the right partner" do
			visit root_path
			# go to the new partner page
			find_link(href: encounters_who_path).click
			select(I18n.t('encounter_whos.new.new_partner'), from: 'who_partnership_id')
			find('input[name="commit"]').click

			@partner = create(:user_profile)

			# get redirected to who
			expect(page).to have_current_path(new_partnership_path)

			# fill in the uid and submit
			fill_in 'partnership_uid', with: @partner.uid
			fill_in_partnership(false)

			#expect a back button
			partnership = @user.reload.partnerships.last
			expect(partnership.uid).to eq @partner.uid
			expect(page).to have_current_path(new_partnership_encounter_path(partnership))
		end
	end

	context "with no uid" do
		scenario "The user ends up on the encounter page with the right partner" do
			visit root_path
			# go to the new partner page
			find_link(href: encounters_who_path).click
			select(I18n.t('encounter_whos.new.new_partner'), from: 'who_partnership_id')
			find('input[name="commit"]').click

			# get redirected to who
			expect(page).to have_current_path(new_partnership_path)

			# fill in the uid and submit
			fill_in_partnership

			#expect a back button
			partnership = @user.reload.partnerships.last
			expect(partnership.partner_id).to eq Profile.last.id
			expect(page).to have_current_path(new_partnership_encounter_path(partnership))
		end
	end
end
