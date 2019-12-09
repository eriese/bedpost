require 'rails_helper'

feature "User creates new partnership", :slow do

	before :each do
		Terms.create(terms: 'terms', type: :tou)
		login_new_user
		@user.update_attributes({first_time: false, tou: Date.today})
	end

	after :each do
		cleanup(@user, @partner)
		Terms.destroy_all
	end

	context 'from the dashboard' do
		scenario 'the partnership who page has a title for step 0' do
			visit root_path
			# go to the new partner page
			find_link(href: who_path).click
			expect(page).to have_selector 'h1#step-0-title'

			#reload and it should still be there
			visit(current_path)
			expect(page).to have_no_selector 'h1#step-0-title'
		end
	end

	context 'from anywhere else' do
		scenario 'the partnership who page has no title for step 0' do
			visit partnerships_path
			find_link(href: who_path).click
			expect(page).to have_no_selector 'h1#step-0-title'
		end
	end

	context "with uid from an existing user" do
		scenario "The flow goes who_path, new_partner_path, partner_path" do
			visit root_path
			# go to the new partner page
			find_link(href: who_path).click

			@partner = create(:user_profile)

			# get redirected to who
			expect(page).to have_current_path(who_path)

			# fill in the uid and submit
			fill_in "partnership_uid", with: @partner.uid
			find('input[name="commit"]').click

			#expect a back button
			expect(page).to have_link(href: who_path)
			fill_out_partnership_form
		end
	end

	context "with no uid" do
		scenario "The flow goes who_path, new_profile_path, new_partner_path, partner_path" do
			# go to the new partner page
			visit root_path
			find_link(href: who_path).click

			# get redirected to who
			expect(page).to have_current_path(who_path)
			partner_params = attributes_for(:no_internal)

			click_on(t("partnership_whos.new.go_new_profile"))
			expect(page).to have_current_path(new_dummy_profile_path)

			partner_params.each do |key, val|
				next if val.nil?
				input_id = "profile_#{key}"
				if key.to_s == "pronoun_id"
					select(Pronoun.find(val).display, from: input_id)
				elsif val.is_a? Boolean
					choose("#{input_id}_#{val}")
				else
					fill_in input_id, with: val
				end
			end

			p_count = Profile.count
			find('input[name="commit"]').click

			expect(Profile.count).to eq(p_count + 1)
			@partner = Profile.last
			#expect no back button
			# expect(page).to_not have_link("Back")
			fill_out_partnership_form
		end
	end

	def fill_out_partnership_form
		# get sent to a page to make a partnership with the person
		expect(page).to have_current_path(new_partnership_path(p_id: @partner.id))
		expect(page).to have_content(t_text("partnerships.new.title_html", {name: @partner.name}))

		# fill in form and submit
		fields = Partnership::LEVEL_FIELDS
		lvls = Array.new(fields.length) {rand(1..10).to_s}
		indexes = (0...fields.length)
		indexes.each do |i|
			fill_in "partnership_#{fields[i]}", with: lvls[i]
		end
		find('input[name="commit"]').click

		# expect to go to the show partnership page
		expect(page).to have_content(t_text("partnerships.show.partner_html", name: @partner.name))
		expect(page).to have_current_path(partnership_path(@user.reload.partnerships.last))
	end
end
