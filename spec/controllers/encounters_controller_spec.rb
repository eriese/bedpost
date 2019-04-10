require 'rails_helper'

RSpec.describe EncountersController, type: :controller do
	def make_user_and_encounters(num_encounters: 0, num_partners: 1)
		@user = create(:user_profile)
		num_partners.times do
			ship = @user.partnerships.create(partner: create(:profile))
			num_encounters.times { ship.encounters << build(:encounter)}
		end
	end

	def user_session
		{user_id: @user.id}
	end

	after :each do
		cleanup @user
	end

	describe 'GET #index' do
		before :each do
			make_user_and_encounters(num_encounters: 2, num_partners: 2)
		end

		context 'with partnership id' do
			it 'shows the encounters for only that partnership' do
				ship = @user.partnerships.first
				get :index, params: {partnership_id: ship.id}, session: user_session

				expect(assigns(:encounters)).to eq ship.encounters
				expect(assigns(:partnership)).to eq ship
				expect(assigns(:encounters)).to_not eq @user.encounters
			end
		end

		context 'without partnership id' do
			it 'shows the encounters for all partnerships the user has' do
				ship = @user.partnerships.first
				get :index, session: user_session

				expect(assigns(:partnership)).to be_nil
				expect(assigns(:encounters)).to eq @user.encounters
			end
		end
	end

	describe 'GET #show' do
		context 'with valid encounter' do
			before do
				make_user_and_encounters num_encounters: 1
			end

			it 'shows the encounter' do
				ship = @user.partnerships.first
				enc = ship.encounters.first
				get :show, params: {partnership_id: ship.to_param, id: enc.to_param}, session: user_session

				expect(assigns[:partnership]).to eq ship
				expect(assigns[:encounter]).to eq enc
			end
		end

		context 'without valid encounter' do
			before do
				make_user_and_encounters
			end

			it 'redirects back or to the encounters_path' do
				ship = @user.partnerships.first
				get :show, params: {partnership_id: ship.to_param, id: "whatever"}, session: user_session

				expect(response).to redirect_to encounters_path
			end
		end
	end

	describe 'GET #new' do
		before :each do
			make_user_and_encounters
		end

		it 'redirects to the encounter who page if the partnership param is invalid' do
			get :new, session: user_session, params: {partnership_id: "whatever"}
			expect(response).to redirect_to encounters_who_path
		end

		it 'makes a new encounter and includes the correct partner' do
			ship = @user.partnerships.first
			get :new, session: user_session, params: {partnership_id: ship.to_param}
			expect(assigns[:encounter]).to be_a Encounter
			expect(assigns[:partner]).to eq ship.partner
		end
	end

	describe 'POST #create' do
		before :each do
			make_user_and_encounters
		end

		context 'with valid params' do
			after :all do
				PossibleContact.delete_all
				Contact::Instrument.delete_all
			end

			it 'creates a new encounter on the partnership' do
				ship = @user.partnerships.first
				post :create, session: user_session, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter)}
				expect(ship.reload.encounters.count).to eq 1
			end

			it 'accepts nested parameters for contacts' do
				ship = @user.partnerships.first
				@hand = create(:contact_instrument, name: :hand)
				create(:possible_contact, subject_instrument: @hand, object_instrument: @hand, contact_type: :touched)
				contact_params = attributes_for(:encounter_contact, subject_instrument_id: @hand.id, object_instrument_id: @hand.id, barriers: ["fresh"])
				enc_params = attributes_for(:encounter, contacts_attributes: [contact_params])
				post :create, session: user_session, params: {partnership_id: ship.to_param, encounter: enc_params}
				ship.reload

				expect(ship.encounters.count).to eq 1
				expect(ship.encounters.first.contacts.count).to eq 1
				expect(ship.encounters.first.contacts.first.barriers).to eq contact_params[:barriers]
			end

			it 'goes to the show page for that encounter' do
				ship = @user.partnerships.first
				post :create, session: user_session, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter)}
				expect(response).to redirect_to partnership_encounter_path(ship, ship.reload.encounters.last)
			end
		end

		context 'with invalid params' do
			it 'reloads the page' do
				ship = @user.partnerships.first
				post :create, session: user_session, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter, self_risk: 11)}

				expect(response).to redirect_to new_partnership_encounter_path(ship)
			end

			it 'does not leave an unsaved partnership on the user' do
				ship = @user.partnerships.first
				post :create, session: user_session, params: {partnership_id: ship.to_param, encounter: attributes_for(:encounter, self_risk: 11)}

				expect(controller.current_user.partnerships.first.encounters.length).to eq 0
			end
		end
	end

	describe 'POST #update' do
		before :each do
			make_user_and_encounters num_encounters: 1
		end

		after :each do
			cleanup(@user, @possible1, @inst1, @inst2)
		end

		context 'with valid params' do
			it 'updates the encounter' do
				ship = @user.partnerships.first
				encounter = ship.encounters.first

				@inst1 = create(:contact_instrument, name: :hand)
	  		@inst2 = create(:contact_instrument, name: :genitals)
        @possible1 = create(:possible_contact, contact_type: :touched, subject_instrument: @inst1, object_instrument: @inst2)

        encounter.contacts << build(:encounter_contact, subject_instrument: @inst1, object_instrument: @inst2, subject: :user, object: :user);

				new_notes = "Something else"
				post :update, session: user_session, params: {id: encounter.to_param, partnership_id: ship.to_param, encounter: {notes: new_notes, contacts_attributes: [{_id: encounter.contacts.first.id, object: :partner}]}}

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

				post :update, session: user_session, params: {id: encounter.to_param, partnership_id: ship.to_param, encounter: {self_risk: 11}}
				expect(response).to redirect_to edit_partnership_encounter_path(ship, encounter)
				expect(flash[:submission_error]).to have_key(:self_risk)
			end
		end
	end

	describe 'DELETE #destroy' do
		after :each do
			cleanup(@user)
		end

		before :each do
			make_user_and_encounters num_encounters: 1
		end

		it 'destroys the requested encounter' do
			ship = @user.partnerships.first
			encounter = ship.encounters.first

			delete :destroy, params: {id: encounter.to_param, partnership_id: ship.to_param}, session: user_session
			expect(ship.reload.encounters.count).to eq 0
		end

		it 'redirects to the encounters index page' do
			ship = @user.partnerships.first
			encounter = ship.encounters.first

			delete :destroy, params: {id: encounter.to_param, partnership_id: ship.to_param}, session: user_session
			expect(response).to redirect_to encounters_path
		end
	end
end
