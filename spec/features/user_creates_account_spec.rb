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
		def user
			UserProfile.find_by(email: @user_params[:email])
		rescue Mongoid::Errors::DocumentNotFound
			nil
		end

		before :all do
			Terms.create(terms: 'some terms', type: :tou)
			Terms.create(terms: 'some privacy terms', type: :privacy)
		end

		after :each do
			cleanup user
		end

		after :all do
			Terms.destroy_all
		end

		def register_user
			visit new_user_profile_registration_path
			@user_params = attributes_for(:user_profile)
			fill_in 'First name*', with: @user_params[:name]
			fill_in 'Email*', with: @user_params[:email]
			fill_in 'Password*', with: @user_params[:password]
			fill_in 'Re-type your password*', with: @user_params[:password]
			click_button "signup-submit"
		end

		def fill_in_profile(user_params = nil, is_user: true)
			user_params ||= @user_params
			model = is_user ? 'user_profile' : 'profile'
			if is_user
				choose("#{model}_opt_in_true")
			else
				fill_in "#{model}_name", with: user_params[:name]
			end
			select(Pronoun.find(user_params[:pronoun_id]).display, from: "#{model}_pronoun_id")
			fill_in "#{model}_anus_name", with: user_params[:anus_name]
			fill_in "#{model}_external_name", with: user_params[:external_name]
			choose("#{model}_can_penetrate_#{user_params[:can_penetrate]}")
			fill_in "#{model}_internal_name", with: user_params[:internal_name]
			click_button 'Save'
		end

		def fill_in_partnership
			fill_in "partnership_nickname", with: "nickname"
			# fill in form and submit
			fields = Partnership::LEVEL_FIELDS
			lvls = Array.new(fields.length) {rand(1..10).to_s}
			indexes = (0...fields.length)
			indexes.each do |i|
				fill_in "partnership_#{fields[i]}", with: lvls[i]
			end
			find('input[name="commit"]').click
		end

		def accept_terms
			find_by_id('terms_acceptance').set(true)
			find('input[name="commit"]').click
		end

		context 'the terms acceptance page' do
			scenario 'the user is redirected first to the tou terms acceptance page' do
				register_user
				expect(page).to have_current_path(term_path(:tou))
				accept_terms
				expect(page).to have_current_path(term_path(:privacy))
			end
			scenario 'the user is next redirected to the privacy terms acceptance page' do
				register_user
				accept_terms
				expect(page).to have_current_path(term_path(:privacy))
				accept_terms
				expect(page).to have_current_path(edit_user_profile_registration_path)
			end
		end

		context 'the edit_user_profile_registration page' do
			before :each do
				register_user
				accept_terms
				accept_terms
			end

			scenario "The user is redirected to the edit_user_profile_registration page" do
				expect(page).to have_current_path(edit_user_profile_registration_path)
			end

			scenario 'The edit user profile page has limited fields' do
				expect(page).to have_no_field('user_profile_name')
				expect(page).to have_no_field('user_profile_uid')
				expect(page).to have_no_content(I18n.t('application.edit.security_settings.title'))
				expect(page).to have_no_content(I18n.t('application.edit.delete_profile.title'))
			end
		end

		context 'after editing the profile' do
			scenario 'the user is marked as set up and taken to the first time page' do
				register_user
				accept_terms
				accept_terms
				fill_in_profile
				expect(user).to be_set_up
				expect(page).to have_current_path(first_time_path)
			end
		end

		context 'the first time page' do
			before :each do
				register_user
				accept_terms
				accept_terms
				fill_in_profile
			end

			scenario 'There is an exit button that allows the user to exit first time' do
				ext = I18n.t("tours.index.exit")
				expect(page).to have_button(ext)
				click_on(ext)
				expect(page).to have_current_path(root_path)
				expect(user).to_not be_first_time
			end
		end

		context 'adding the first partner' do
			scenario 'filling in the partnership form brings the user back to the first_time page' do
				register_user
				accept_terms
				accept_terms
				fill_in_profile
				find("a[href='#{new_partnership_path}']").click

				click_on("No")
				find("a[href='#{new_dummy_profile_path}']").click

				fill_in_profile attributes_for(:profile), is_user: false
				fill_in_partnership

				expect(page).to have_current_path(first_time_path)
			end
		end

		context 'adding the first encounter' do
			before :each do
				@hand = create(:contact_instrument, name: :hand)
				@p1 = create(:possible_contact, contact_type: :touched, subject_instrument: @hand, object_instrument: @hand)
			end

			after :each do
				cleanup user, @p1, @hand
			end

			scenario 'the show encounter page has a button back to the first time page' do
				register_user
				accept_terms
				accept_terms
				fill_in_profile
				find("a[href='#{new_partnership_path}']").click
				click_on("No")
				find("a[href='#{new_dummy_profile_path}']").click

				fill_in_profile attributes_for(:profile), is_user: false
				fill_in_partnership

				ship = user.partnerships.first
				new_enc_path = new_partnership_encounter_path(ship)
				find("a[href='#{new_enc_path}']").click

				# skip filling out that form
				expect(page).to have_current_path(new_enc_path)
				ship.encounters << build(:encounter, contacts: [build(:encounter_contact, possible_contact: @p1)])
				user.save

				# go to the view page
				visit partnership_encounter_path(ship, ship.encounters.first)
				expect(page).to have_link({href: first_time_path})
			end
		end
	end
end
