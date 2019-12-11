require 'rails_helper'

RSpec.describe EncountersController, type: :controller do
	def make_user_and_encounters(num_encounters: 0, num_partners: 1)
		@user = create(:user_profile)
		sign_in @user
		@hand = create(:contact_instrument, name: :hand)
		@mouth = create(:contact_instrument, name: :mouth)
		@p1 = create(:possible_contact, contact_type: :penetrated, subject_instrument: @hand, object_instrument: @mouth)

		num_partners.times do
			ship = @user.partnerships.create(partner: create(:profile))
			num_encounters.times do
				enc = build(:encounter)
				enc.contacts << build(:encounter_contact, possible_contact: @p1)
				ship.encounters << enc
			end
		end
	end

	after :each do
		cleanup @user, @p1, @p2, @hand, @mouth
	end

	describe 'GET #index' do
		before :each do
			allow(controller).to receive(:check_first_time)
		end

		context 'with partnership id' do
			before :each do
				make_user_and_encounters(num_encounters: 2, num_partners: 2)
			end

			it 'shows the encounters for only that partnership' do
				ship = @user.partnerships.first
				get :index, params: {partnership_id: ship.id}

				actual = assigns(:partnerships)
				expect(actual.size).to eq 1
				expect(actual[0]["_id"]).to eq ship.id
			end

			it 'indicates that this is a request for only one partner' do
				ship = @user.partnerships.first
				get :index, params: {partnership_id: ship.id}
				expect(assigns(:is_partner)).to be true
			end
		end

		context 'without partnership id' do
			it 'shows the encounters for all partnerships the user has' do
				num_partners = 2
				make_user_and_encounters(num_encounters: 2, num_partners: num_partners)
				get :index

				expect(assigns(:partnerships).size).to eq num_partners
			end

			it 'indicates that this is a request for all partners even if there is only one partner' do
				make_user_and_encounters(num_encounters: 2, num_partners: 1)
				get :index
				expect(assigns(:is_partner)).to be false
			end
		end
	end

	describe 'GET #show' do
		context 'with valid encounter' do
			before do
				make_user_and_encounters num_encounters: 1
				allow(Diagnosis).to receive(:as_map) {{hpv: build_stubbed(:diagnosis, name: :hpv)}}
				allow_any_instance_of(Encounter::RiskCalculator).to receive(:schedule) { {routine: [:hpv]}}
			end

			it 'shows the encounter' do
				ship = @user.partnerships.first
				enc = ship.encounters.first
				get :show, params: {partnership_id: ship.to_param, id: enc.to_param}

				expect(assigns[:partnership]).to eq ship
				expect(assigns[:encounter]).to eq enc
				expect(assigns[:encounter].schedule).to_not be_nil
			end

			describe 'params[:force]' do
				it 'default runs without force' do
					ship = @user.partnerships.first
					enc = ship.encounters.first
					expect_any_instance_of(Encounter::RiskCalculator).to receive(:track).with(force: nil)
					get :show, params: {partnership_id: ship.to_param, id: enc.to_param}
					expect(assigns(:force)).to be_nil
				end

				it 'forces test scheduling even on lower risks when force is true' do
					ship = @user.partnerships.first
					enc = ship.encounters.first
					expect_any_instance_of(Encounter::RiskCalculator).to receive(:track).with(force: "true")
					get :show, params: {partnership_id: ship.to_param, id: enc.to_param, force: "true"}
					expect(assigns(:force)).to eq "true"
				end

				it 'responds with the html representation of the forced schedule if requested in json' do
					ship = @user.partnerships.first
					enc = ship.encounters.first
					get :show, params: {partnership_id: ship.to_param, id: enc.to_param, force: "true"}, format: :json
					expect(response.body).to eq controller.helpers.display_schedule(assigns(:encounter))
				end

				it 'responds with the full show page if requested in html' do
					ship = @user.partnerships.first
					enc = ship.encounters.first
					get :show, params: {partnership_id: ship.to_param, id: enc.to_param, force: "true"}
					expect(response).to render_template :show
				end
			end
		end

		context 'without valid encounter' do
			before do
				make_user_and_encounters
			end

			it 'redirects back or to the encounters_path' do
				ship = @user.partnerships.first
				get :show, params: {partnership_id: ship.to_param, id: "whatever"}

				expect(response).to redirect_to encounters_path
			end
		end
	end

	describe 'GET #new' do
		before :each do
			make_user_and_encounters
		end

		it 'redirects to the encounter who page if the partnership param is invalid' do
			get :new, params: {partnership_id: "whatever"}
			expect(response).to redirect_to encounters_who_path
		end

		it 'redirects to the encounter who page if there is no partnership param is invalid' do
			get :new, params: {partnership_id: "whatever"}
			expect(response).to redirect_to encounters_who_path
		end

		it 'makes a new encounter and includes the correct partner' do
			ship = @user.partnerships.first
			get :new, params: {partnership_id: ship.to_param}
			expect(assigns[:encounter]).to be_a Encounter
			expect(assigns[:partner]).to eq ship.partner
		end
	end

	describe 'POST #create' do
		before :each do
			make_user_and_encounters
		end

		context 'with valid params' do

			it 'creates a new encounter on the partnership' do
				ship = @user.partnerships.first
				contact_params = [attributes_for(:encounter_contact, possible_contact_id: @p1.id)]
				post :create, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter, contacts_attributes: contact_params)}
				expect(ship.reload.encounters.count).to eq 1
			end

			it 'accepts nested parameters for contacts' do
				ship = @user.partnerships.first
				@p2 = create(:possible_contact, subject_instrument: @hand, object_instrument: @hand, contact_type: :touched)
				contact_params = [attributes_for(:encounter_contact, possible_contact_id: @p1.id), attributes_for(:encounter_contact, possible_contact_id: @p2.id, barriers: ["fresh"])]
				enc_params = attributes_for(:encounter, contacts_attributes: contact_params)
				post :create, params: {partnership_id: ship.to_param, encounter: enc_params}
				ship.reload

				expect(ship.encounters.count).to eq 1
				expect(ship.encounters.first.contacts.count).to eq 2
				expect(ship.encounters.first.contacts.last.barriers).to eq contact_params[1][:barriers].map(&:intern)
			end

			it 'goes to the show page for that encounter' do
				ship = @user.partnerships.first
				contact_params = [attributes_for(:encounter_contact, possible_contact_id: @p1.id)]
				post :create, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter, contacts_attributes: contact_params)}
				expect(response).to redirect_to partnership_encounter_path(ship, ship.reload.encounters.last)
			end
		end

		context 'with invalid params' do
			it 'reloads the page' do
				ship = @user.partnerships.first
				contact_params = [attributes_for(:encounter_contact, possible_contact_id: @p1.id)]
				post :create, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter, contacts_attributes: contact_params, self_risk: 11)}

				expect(response).to redirect_to new_partnership_encounter_path(ship)
			end

			it 'does not leave an unsaved partnership on the user' do
				ship = @user.partnerships.first
				contact_params = [attributes_for(:encounter_contact, possible_contact_id: @p1.id)]
				post :create, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter, contacts_attributes: contact_params, self_risk: 11)}

				expect(controller.current_user_profile.partnerships.first.encounters.length).to eq 0
			end

			it 'errors gacefully with bad contacts params' do
				ship = @user.partnerships.first
				contact_params = [attributes_for(:encounter_contact, possible_contact_id: nil)]
				encounter_params = attributes_for(:encounter, contacts_attributes: contact_params)
				post :create, format: :json, params: {partnership_id: ship.to_param, encounter: encounter_params}

				actual = response.body
				expected_enc = Encounter.new(encounter_params)
				expected_enc.valid?
				expected = expected_enc.errors.messages.to_json
				expect(actual).to eq expected.to_s
			end
		end
	end

	describe 'POST #update' do
		before :each do
			allow(controller).to receive(:check_first_time)
			make_user_and_encounters num_encounters: 1
		end

		after :each do
			cleanup(@user, @possible1, @genitals)
		end

		context 'with valid params' do
			it 'updates the encounter' do
				ship = @user.partnerships.first
				encounter = ship.encounters.first

				@genitals = create(:contact_instrument, name: :genitals)
				@possible1 = create(:possible_contact, contact_type: :touched, subject_instrument: @hand, object_instrument: @genitals)

				encounter.contacts << build(:encounter_contact, possible_contact: @possible1, subject: :user, object: :user);

				new_notes = "Something else"
				post :update, params: {id: encounter.to_param, partnership_id: ship.to_param, encounter: {notes: new_notes, contacts_attributes: [{_id: encounter.contacts.first.id, object: :partner}]}}

				encounter.reload
				expect(encounter.notes).to eq new_notes
				expect(encounter.contacts.first.object).to eq :partner
				expect(ship.reload.encounters.first.notes).to eq new_notes
			end
		end

		context 'with invalid params' do
			it 'responds with the error' do
				ship = @user.partnerships.first
				encounter = ship.encounters.first

				post :update, params: {id: encounter.to_param, partnership_id: ship.to_param, encounter: {self_risk: 11}}
				expect(response).to redirect_to edit_partnership_encounter_path(ship, encounter)
				expect(flash[:submission_error]).to have_key(:self_risk)
			end
		end
	end

	describe 'DELETE #destroy' do

		before :each do
			allow(controller).to receive(:check_first_time)
			make_user_and_encounters num_encounters: 1
		end

		it 'destroys the requested encounter' do
			ship = @user.partnerships.first
			encounter = ship.encounters.first
			expect(encounter).to_not be_nil

			delete :destroy, params: {id: encounter.to_param, partnership_id: ship.to_param}
			expect(ship.reload.encounters.count).to eq 0
		end

		it 'redirects to the encounters index page' do
			ship = @user.partnerships.first
			encounter = ship.encounters.first

			delete :destroy, params: {id: encounter.to_param, partnership_id: ship.to_param}
			expect(response).to redirect_to encounters_path
		end
	end
end
