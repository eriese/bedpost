require 'rails_helper'

RSpec.describe UserProfile, type: :model do
	context 'fields' do
		describe '#uid' do
			it 'generates a uid on initialization' do
				user1 = build(:user_profile)
				expect(user1.uid).to_not be nil
			end

			it "doesn't allow duplicate uids" do
				user1 = build(:user_profile, uid: dummy_user.uid)
				expect(user1).to_not be_valid
				expect(user1).to have_validation_error_for(:uid, :taken)
			end
		end

		describe '#email' do
			it 'requires an email' do
				user1 = build(:user_profile, email: nil)
				expect(user1).to_not be_valid
				expect(user1).to have_validation_error_for(:email, :blank)
			end

			it 'lowercases emails on initialization' do
				email = 'UPPERCASE@example.com'
				user1 = build(:user_profile, email: email)
				expect(user1.email).to eq email.downcase
			end

			it "doesn't allow duplicate emails" do
				user1 = build(:user_profile, email: dummy_user.email)
				expect(user1).to_not be_valid
				expect(user1).to have_validation_error_for(:email, :taken)
			end
		end

		describe '#password' do
			it 'generates a password hash' do
				original = attributes_for(:user_profile)[:password]
				actual = dummy_user.valid_password?(original)
				expect(actual).to be true
			end

			it 'requires a minimum length of 7' do
				validator = UserProfile.validators_on(:password).find { |v|
					v.is_a?(Mongoid::Validatable::LengthValidator) && v.options[:minimum] == 7
				}
				expect(validator).to_not be_nil
			end

			it 'requires a maximum length of 72' do
				validator = UserProfile.validators_on(:password).find { |v|
					v.is_a?(Mongoid::Validatable::LengthValidator) && v.options[:maximum] == 72
				}
				expect(validator).to_not be_nil
			end
		end
	end

	context 'methods' do
		describe '#as_json' do
			it 'does not include the passsword or encrypted_password' do
				user = build_stubbed(:user_profile)
				result = user.as_json

				expect(result).to_not include('encrypted_password')
				expect(result).to_not include('password')
			end
		end

		describe '#update_without_password' do
			before :each do
				@user = create(:user_profile)
			end

			after :each do
				cleanup(@user)
			end

			it 'never updates the password' do
				oldPass = @user.encrypted_password
				params = { name: 'new name', password: 'new password', password_confirmation: 'new password' }
				@user.update_without_password(params)
				@user.reload
				expect(@user.name).to eq params[:name]
				expect(@user.encrypted_password).to eq oldPass
			end

			it 'never updates the email' do
				oldEmail = @user.email
				params = { name: 'new name', email: 'newEmail@mail.com' }
				@user.update_without_password(params)
				@user.reload
				expect(@user.name).to eq params[:name]
				expect(@user.email).to eq oldEmail
			end
		end

		describe '#set_up?' do
			after :each do
				cleanup(@user)
			end

			it 'returns false if the user has registered but not filled in all profile details' do
				@user = UserProfile.create(name: 'Name', email: 'email@email.com', password: 'password',
																															password_confirmation: 'password')
				expect(@user).to be_persisted
				expect(@user).to_not be_set_up
			end

			it 'returns true if the user has filled out all profile details' do
				user = build_stubbed(:user_profile)
				expect(user).to be_set_up
			end
		end

		describe '#first_time?' do
			it 'defaults to true' do
				user = UserProfile.new
				expect(user).to be_first_time
			end
		end

		describe '#has_toured?' do
			it 'returns true if the user has toured the given page' do
				user = build_stubbed(:user_profile)
				user.tours = ['page-false']
				expect(user).to have_toured('page', false)
			end

			it 'returns false if the user has not toured the given page' do
				user = build_stubbed(:user_profile)
				expect(user).to_not have_toured('page', false)
			end
		end

		describe '#tour' do
			after :each do
				cleanup @user
			end

			it 'adds a page to a the tour set and saves' do
				@user = create(:user_profile)
				expect(@user.tour('page', false)).to be true
				@user.reload
				expect(@user.tours).to be_a Set
				expect(@user.tours).to include('page-false')
			end

			it 'returns true if the user has already toured the page, but does not add a duplicate' do
				@user = create(:user_profile, tours: ['page-false'])
				expect(@user.tour('page', false)).to be true
			end
		end

		describe '#partners_with_most_recent' do
			before :all do
				@hand = create(:contact_instrument, name: :hand)
				@pos = create(:possible_contact, subject_instrument: @hand, object_instrument: @hand)
			end

			after :all do
				cleanup @pos, @hand
			end

			before :each do
				@user = create(:user_profile)
				@p1 = create(:profile, name: 'Fred')
				@p2 = create(:profile, name: 'Andy')

				@p1_nickname = 'friend'
				@p2_nickname = 'lover'
				@user.partnerships = [build(:partnership, partner: @p1, nickname: @p1_nickname),
																										build(:partnership, partner: @p2, nickname: @p2_nickname)]
			end

			after :each do
				cleanup @user
			end

			it 'gets a query of the partners the user has with the partnership id, most recent encounter, nickname, and partner name' do
				p1_last = Date.new(2019, 10, 31)
				p2_last = Date.new(2019, 8, 24)

				@user.encounters = [
					build(:encounter, took_place: p1_last, partnership: @user.partnerships.first,
																							contacts: [build(:encounter_contact, possible_contact: @pos)]),
					build(:encounter, took_place: p1_last - 1.day, partnership: @user.partnerships.first,
																							contacts: [build(:encounter_contact, possible_contact: @pos)]),
					build(:encounter, took_place: p2_last, partnership: @user.partnerships.last,
																							contacts: [build(:encounter_contact, possible_contact: @pos)])
				]

				@user.save

				result = @user.partners_with_most_recent.to_a

				ship1 = result[0]
				expect(ship1['_id']).to eq @user.partnerships.first.id
				expect(ship1['most_recent']).to eq p1_last
				expect(ship1['nickname']).to eq @p1_nickname
				expect(ship1['partner_name']).to eq @p1.name

				ship2 = result[1]
				expect(ship2['_id']).to eq @user.partnerships.last.id
				expect(ship2['most_recent']).to eq p2_last
				expect(ship2['nickname']).to eq @p2_nickname
				expect(ship2['partner_name']).to eq @p2.name
			end

			it 'sorts by most recent' do
				p1_last = Date.new(2019, 8, 24)
				p2_last = Date.new(2019, 10, 31)

				@user.encounters = [
					build(:encounter, took_place: p1_last, partnership: @user.partnerships.first,
																							contacts: [build(:encounter_contact, possible_contact: @pos)]),
					build(:encounter, took_place: p2_last, partnership: @user.partnerships.last,
																							contacts: [build(:encounter_contact, possible_contact: @pos)])
				]

				result = @user.partners_with_most_recent.to_a
				expect(result[0]['most_recent']).to eq p2_last
			end

			it 'gracefully handles partnerships with no encounters' do
				@user.encounters = [
					build(:encounter, took_place: Date.new(2019, 10, 31), partnership: @user.partnerships.first,
																							contacts: [build(:encounter_contact, possible_contact: @pos)])
				]

				result = @user.partners_with_most_recent.to_a
				expect(result.size).to be 2
				expect(result[0]['_id']).to eq @user.partnerships.first.id
				expect(result[1]['most_recent']).to be_nil
			end
		end

		describe '#terms_accepted?' do
			after :each do
				Terms.destroy_all
			end

			it 'returns false if the user has not accepted the given terms type yet' do
				Terms.create(terms: 'some terms', type: :tou)
				user = build_stubbed(:user_profile_new)
				expect(user).not_to be_terms_accepted(:tou)
			end

			it 'returns false if the latest terms of use were created after the user accepted terms of use' do
				tou = Terms.create(terms: 'some terms', type: :tou)
				user = build_stubbed(:user_profile, terms: { tou: tou.updated_at - 1.day })
				expect(user).not_to be_terms_accepted(:tou)
			end

			it 'returns true if the latest terms of use were created before the user accepted terms of use' do
				tou = Terms.create(terms: 'some terms', type: :tou)
				user = build_stubbed(:user_profile, terms: { tou: tou.updated_at + 1.day })
				expect(user).to be_terms_accepted(:tou)
			end

			it 'returns true if the user accepted on the same day the terms were created' do
				tou = Terms.create(terms: 'some terms', type: :tou)
				user = build_stubbed(:user_profile, terms: { tou: tou.updated_at })
				expect(user).to be_terms_accepted(:tou)
			end
		end

		describe '#accept_terms' do
			after do
				cleanup @user
			end
			it 'marks the given terms as accepted on the current datetime' do
				now = 'foo'
				allow(DateTime).to receive(:now) { now }
				@user = create(:user_profile_new)

				@user.accept_terms :tou
				@user.reload
				expect(@user.terms[:tou]).to eq now
			end
		end

		describe '#partners_with_profiles' do
			before do
				@user = create(:user_profile)
				@p1 = create(:profile, name: 'Fred')
				@p2 = create(:profile, name: 'Andy')

				@p1_nickname = 'friend'
				@p2_nickname = 'lover'
				@user.partnerships = [build(:partnership, partner: @p1, nickname: @p1_nickname),
																										build(:partnership, partner: @p2, nickname: @p2_nickname)]
			end

			after do
				cleanup @user, @p1, @p2
			end

			it 'returns a list of the partnerships the user has' do
				result = @user.partners_with_profiles.as_json

				expect(result.size).to be 2
			end

			it 'attaches the partnership id as _id' do
				result = @user.partners_with_profiles.as_json
				expect(result[0]['_id']).to eq @user.partnerships.first.id.to_s
			end

			it 'has all needed fields' do
				fred = @user.partners_with_profiles.as_json[0]
				expect(fred['partner_name']).to eq "#{@p1.name} #{@p1_nickname}"
				expect(fred['pronoun_id']).to eq @p1.pronoun_id.to_s
				['name', 'anus_name', 'external_name', 'internal_name', 'can_penetrate'].each do |f|
					expect(fred[f]).to eq @p1.send(f)
				end
			end
		end

		describe '#partners_with_encounters' do
			before :all do
				@hand = create(:contact_instrument, name: :hand)
				@pos = create(:possible_contact, subject_instrument: @hand, object_instrument: @hand)
			end

			after :all do
				cleanup @pos, @hand
			end

			before :each do
				@user = create(:user_profile)
				@p1 = create(:profile, name: 'Fred')
				@p2 = create(:profile, name: 'Andy')

				@p1_nickname = 'friend'
				@p2_nickname = 'lover'

				ship1 = build(:partnership, partner: @p1, nickname: @p1_nickname)
				ship2 = build(:partnership, partner: @p2, nickname: @p2_nickname)
				@user.partnerships = [ship1, ship2]

				p1_last = Date.new(2019, 10, 31)
				p2_last = Date.new(2019, 8, 24)

				@user.encounters = [
					build(:encounter, took_place: p1_last, contacts: [build(:encounter_contact, possible_contact: @pos)],
																							partnership: ship1),
					build(:encounter, took_place: p1_last - 1.day, contacts: [build(:encounter_contact, possible_contact: @pos)],
																							partnership: ship1),
					build(:encounter, took_place: p2_last, contacts: [build(:encounter_contact, possible_contact: @pos)],
																							partnership: ship2)
				]

				@user.save
			end

			after :each do
				cleanup @user
			end

			context 'without a partnership_id' do
				it 'gets a query of the partners the user has with the partnership id, nickname, partner name, and encounters took_place and notes' do
					result = @user.partners_with_encounters.to_a

					expect(result.size).to be @user.partnerships.size

					r_ship1 = result[0]
					u_ship1 = @user.partnerships.find(r_ship1['_id'])
					expect(r_ship1['encounters'].size).to be u_ship1.encounters.size
					expect(r_ship1['partner_name']).to eq u_ship1.partner.name
					expect(r_ship1['nickname']).to eq u_ship1.nickname

					r_ship1_enc0 = r_ship1['encounters'][0]
					u_ship1_enc0 = @user.encounters.find(r_ship1_enc0['_id'])
					expect(r_ship1_enc0['partnership_id']).to eq u_ship1.id
					expect(r_ship1_enc0).to have_key 'took_place'
					expect(r_ship1_enc0).to have_key 'notes'
				end

				it 'excludes partners with no encounters' do
					@user.partnerships.last.encounters.destroy_all

					result = @user.partners_with_encounters.to_a
					expect(result.size).to be @user.partnerships.size - 1
					expect(result.any? { |ship| ship['_id'] == @user.partnerships.last.id }).to be false
				end
			end

			context 'with a partnership_id' do
				it 'gets details on just one partner if a partner_id is given' do
					u_ship2 = @user.partnerships[1]
					result = @user.partners_with_encounters(u_ship2.id).to_a

					expect(result.size).to be 1
					r_ship2 = result[0]
					expect(r_ship2['_id']).to eq u_ship2.id
					expect(r_ship2['encounters'].size).to be u_ship2.encounters.size
					expect(r_ship2['partner_name']).to eq @p2.name
					expect(r_ship2['nickname']).to eq u_ship2.nickname
				end

				it 'works with a string id' do
					u_ship1 = @user.partnerships[0]
					id_string = u_ship1.id.to_s
					result = @user.partners_with_encounters(id_string).to_a

					expect(result.size).to be 1
				end
			end
		end

		describe '#soft_destroy' do
			before :each do
				@user = create(:user_profile)
			end

			after :each do
				cleanup(@user, @partner, @dummy)
			end

			it 'sends a removal confirmation email' do
				allow(RegistrationMailer).to receive(:removal).and_call_original
				expect(@user.soft_destroy).to be true
				expect(RegistrationMailer).to have_received(:removal).with(@user.id.to_s, @user.email, @user.name, @user.opt_in)
			end

			context 'with a user with #opt_in = true' do
				before :each do
					@user.update(opt_in: true)
				end

				it 'replaces the email address, name, and uid' do
					orig_name = @user.name
					expect(@user.soft_destroy).to be true
					@user.reload
					expect(@user.name).not_to eq orig_name
					expect(@user.email).to eq "#{@user.name}@bedpost.me"
					expect(@user.uid).to eq @user.name
				end

				it 'sets a deleted_at timestamp' do
					expect(@user.soft_destroy).to be true
					@user.reload
					expect(@user.deleted_at).to_not be_nil
				end
			end

			context 'with a user with #opt_in = false' do
				it 'calls destroy on the user' do
					allow(@user).to receive(:destroy).and_call_original
					expect(@user.soft_destroy).to be true
					expect(@user).to have_received(:destroy)
				end

				it 'creates a placeholder user with the same preferences as the user if the user is partnered to any other user profiles' do
					@partner = create(:user_profile)
					@partner.partnerships << build(:partnership, partner_id: @user.id)
					@user.reload
					partnered_to_ids = described_class.where_partnered_to(@user.id).pluck(:_id)
					expect(partnered_to_ids).to_not be_empty

					expect(@user.soft_destroy).to be true
					@dummy = Profile.last unless Profile.last.id == @partner.id
					expect(@dummy.name).to eq @user.name

					dummy_partnered_to_ids = described_class.where_partnered_to(@dummy.id).pluck(:_id)
					expect(dummy_partnered_to_ids).to eq partnered_to_ids
				end
			end
		end

		describe '#self.where_partnered_to' do
			after do
				cleanup @user
			end

			it 'returns a query for UserProfiles that have a partnership with the given profile_id' do
				@user = create(:user_profile)
				@partner = create(:profile)

				@user.partnerships.create(partner: @partner)
				result = described_class.where_partnered_to(@partner.id)
				expect(result.first).to eq @user
			end
		end
	end

	context 'embedded' do
		it_should_behave_like 'an object that dirty-tracks its embedded relations', UserProfile, :user_profile

		context 'partnerships' do
			after :each do
				cleanup(@user, @partner)
			end

			it 'destroys dummy partners when it is destroyed' do
				@user = create(:user_profile)
				@partner = create(:profile)
				clean_mailer_jobs

				@user.partnerships.create(partner: @partner)
				expect {
					@user.destroy
					work_jobs
				}.to change(Profile, :count).by(-2)
				expect(@user).to be_destroyed
				expect(Profile.where(id: @partner.id).count).to eq 0
			end
		end
	end

	context 'validations' do
		it 'only requires a pronoun on update' do
			user1 = build(:user_profile, pronoun: nil)
			expect(user1).to be_valid

			user2 = build_stubbed(:user_profile, pronoun: nil)
			expect(user2).to_not be_valid
			expect(user2).to have_validation_error_for(:pronoun, :blank)
		end

		it 'only requires a name for the anus on update' do
			user1 = build(:user_profile, anus_name: nil)
			expect(user1).to be_valid

			user2 = build_stubbed(:user_profile, anus_name: nil)
			expect(user2).to_not be_valid
			expect(user2).to have_validation_error_for(:anus_name, :blank)
		end

		it 'only requires a name for the external genitals on update' do
			user1 = build(:user_profile, external_name: nil)
			expect(user1).to be_valid

			user2 = build_stubbed(:user_profile, external_name: nil)
			expect(user2).to_not be_valid
			expect(user2).to have_validation_error_for(:external_name, :blank)
		end
	end
end
