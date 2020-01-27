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

		context 'the terms acceptance page' do
			scenario 'the user is redirected first to the tou terms acceptance page' do
				register_user
				expect(page).to have_current_path(term_path(:tou))
				accept_terms
				expect(page).to have_current_path(edit_user_profile_registration_path)
			end
		end

		context 'the edit_user_profile_registration page' do
			before :each do
				register_user
				accept_terms
			end

			scenario "The user is redirected to the edit_user_profile_registration page" do
				expect(page).to have_current_path(edit_user_profile_registration_path)
			end

			scenario 'The edit user profile page has limited fields' do
				expect(page).to have_no_field 'user_profile_opt_in_true'
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
				fill_in_profile
				expect(user).to be_set_up
				expect(page).to have_current_path(first_time_path)
			end
		end

		context 'when visiting the first time page' do
			before do
				register_user
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

		context 'when adding the first partner' do
			scenario 'filling in the partnership form brings the user back to the first_time page' do
				register_user
				accept_terms
				fill_in_profile
				find("a[href='#{new_partnership_path}']").click

				fill_in_partnership

				expect(page).to have_current_path(first_time_path)
			end
		end

		context 'when adding the first encounter' do
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
				fill_in_profile
				find("a[href='#{new_partnership_path}']").click

				fill_in_partnership

				ship = user.partnerships.first
				new_enc_path = new_partnership_encounter_path(ship)
				click_on(I18n.t('tours.index.add_encounter'))
				# find("a[href='#{new_enc_path}']").click

				# skip filling out that form
				expect(page).to have_current_path(new_enc_path)
				ship.encounters << build(:encounter, contacts: [build(:encounter_contact, possible_contact: @p1)])
				user.save

				# go to the view page
				visit partnership_encounter_path(ship, ship.encounters.first)
				expect(page).to have_link({href: first_time_path})
			end
		end

		context 'when adding an encounter after adding a second partner' do
			after do
				cleanup user, @partner1, @partner2
			end

			scenario 'it goes to the encounter who page' do
				register_user
				accept_terms
				fill_in_profile

				@partner1 = create(:profile)
				@partner2 = create(:profile)
				user.partnerships += [
					build(:partnership, partner: @partner1),
					build(:partnership, partner: @partner2)
				]
				user.save

				visit page.current_path

				click_on(I18n.t('tours.index.add_encounter'))
				expect(page).to have_current_path(encounters_who_path)
			end
		end
	end
end
