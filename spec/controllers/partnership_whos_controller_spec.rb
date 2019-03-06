require 'rails_helper'

RSpec.describe PartnershipWhosController, type: :controller do
	describe 'POST #create' do
		it 'does not leave an unsaved partnership on the user' do
			user = create(:user_profile)
			post :create, session: {user_id: user.id}, params: {partnership: {uid: "nonsense"}}

			expect(controller.current_user.partnerships.length).to eq 0
		ensure
			user.destroy
		end

		context 'with a valid uid' do
			it 'forwards to the create partnership page with the partner id of the given user' do
				user = create(:user_profile)
				partner = create(:user_profile)
				post :create, session: {user_id: user.id}, params: {partnership: {uid: partner.uid}}

				expect(response).to redirect_to new_partnership_path(p_id: partner.id)
			ensure
				user.destroy
				partner.destroy
			end
		end
	end

	describe 'GET #new with a partnership' do
		context 'with a valid partnership' do
			it 'puts the partnership on the page to be edited' do
				user = create(:user_profile)
				old_partner = create(:profile)
				ship = user.partnerships.create(partner: old_partner)

				get :new, session: {user_id: user.id}, params: {partnership_id: ship.to_param}
				expect(assigns[:partnership]).to eq ship
			ensure
				user.destroy
				old_partner.destroy
			end
		end

		context 'with invalid partnership' do
			it 'redirects to the partnerships index page' do
				get :new, session: dummy_user_session, params: {partnership_id: "random"}
				expect(response).to redirect_to partnerships_path
			end
		end
	end

	describe 'PUT #update' do
		context 'with a valid uid' do
			it 'updates the partner id on the partnership' do
				user = create(:user_profile)
				old_partner = create(:profile)
				ship = user.partnerships.create(partner: old_partner)

				put :update, session: {user_id: user.id}, params: {partnership_id: ship.to_param, partnership: {uid: dummy_user.uid}}
				ship.reload
				expect(ship.partner_id).to eq dummy_user.id
			ensure
				user.destroy
				old_partner.destroy
			end

			it 'deletes the orphaned dummy partner' do
				user = create(:user_profile)
				old_partner = create(:profile)
				ship = user.partnerships.create(partner: old_partner)

				put :update, session: {user_id: user.id}, params: {partnership_id: ship.to_param, partnership: {uid: dummy_user.uid}}
				expect{Profile.find(old_partner.id)}.to raise_error(Mongoid::Errors::DocumentNotFound)
			ensure
				user.destroy
				old_partner.destroy
			end
		end
	end
end
