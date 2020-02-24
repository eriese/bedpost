require 'rails_helper'

feature "User creates new partnership through encounter", :slow do

	before :each do
		Terms.create(terms: 'some terms', type: :tou)
		Terms.create(terms: 'some other terms', type: :privacy)
		login_new_user
		accept_date = DateTime.now + 1
		@user.update_attributes({first_time: false, terms: {tou: accept_date, privacy: accept_date}})
	end

	after :each do
		cleanup(@user, @partner)
		Terms.destroy_all
	end

	context "with uid from an existing user" do
		scenario "The user ends up on the encounter page with the right partner" do
			visit root_path
			expect(page).to have_current_path(root_path)
			# go to the new encounter page
			find_link(href: new_encounter_path).click
			select(I18n.t('encounter_whos.new.new_partner'), from: 'encounter_partnership_id')
			find('input[name="commit"]').click

			@partner = create(:user_profile)

			# get redirected to new partnership
			expect(page).to have_current_path(new_partnership_path)

			# fill in the partnership with the uid and submit
			fill_in 'partnership_uid', with: @partner.uid
			fill_in_partnership(false)

			#expect to land on a new encounter form for the partnership
			partnership = @user.reload.partnerships.last
			expect(partnership.uid).to eq @partner.uid
			expect(page).to have_current_path(new_partnership_encounter_path(partnership))
		end
	end

	context "with no uid" do
		scenario "The user ends up on the encounter page with the right partner" do
			visit root_path
			expect(page).to have_current_path(root_path)
			# go to the new encounter page
			find_link(href: new_encounter_path).click
			select(I18n.t('encounter_whos.new.new_partner'), from: 'encounter_partnership_id')
			find('input[name="commit"]').click

			# get redirected to new partnership
			expect(page).to have_current_path(new_partnership_path)

			# fill in the profile details and partnership and submit
			fill_in_partnership

			#expect to land on a new encounter form for the partnership
			partnership = @user.reload.partnerships.last
			expect(partnership.partner_id).to eq Profile.last.id
			expect(page).to have_current_path(new_partnership_encounter_path(partnership))
		end
	end
end
