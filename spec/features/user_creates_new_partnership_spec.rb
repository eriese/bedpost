require 'rails_helper'

feature "User creates new partnership", :slow do

	before :each do
		login_new_user
		# go to the new partner page
		find_link(href: new_partnership_path).click
	end

	after :each do
		@user.destroy
		@partner.destroy if @partner
	end

	context "with uid from an existing user" do
		scenario "The flow goes who_path, new_partner_path, partner_path" do
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
			# get redirected to who
			expect(page).to have_current_path(who_path)

			click_on(t("whos.new.new_profile"))
			expect(page).to have_current_path(new_profile_path)

			partner_params = attributes_for(:no_internal)
			partner_params.each do |key, val|
				next if val.nil?
				input_id = "profile_#{key}"
				if key.to_s == "pronoun"
					select(val.display, from: input_id)
				else
					fill_in input_id, with: val
				end
			end

			find('input[name="commit"]').click

			@partner = Profile.last
			#expect no back button
			expect(page).to_not have_link("Back")
			fill_out_partnership_form
		end
	end

	def fill_out_partnership_form
		# get sent to a page to make a partnership with the person
		expect(page).to have_current_path(new_partnership_path(p_id: @partner.id))
		expect(page).to have_content(t_text("partnerships.new.partner_html", {name: @partner.name}))

		# fill in form and submit
		fields = Partnership::LEVEL_FIELDS
		lvls = Array.new(fields.length) {rand(1..10).to_s}
		indexes = (0...fields.length)
		indexes.each do |i|
			fill_in "partnership_#{fields[i]}", with: lvls[i]
		end
		find('input[name="commit"]').click

		# expect to go to the show partnership page
		expect(page).to have_content(t_text("partnerships.show.partner_html", name: @partner.name, nickname: nil))
		indexes.each do |i|
			expect(page).to have_content(t_text("partnerships.show.level_field_html", field: fields[i], level: lvls[i]))
		end
	end
end
