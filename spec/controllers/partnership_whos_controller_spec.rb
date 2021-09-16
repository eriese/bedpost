require 'rails_helper'

RSpec.describe PartnershipWhosController, type: :controller do
	after :each do
		cleanup @user, @partner, @old_partner
	end

	describe 'GET #edit with a partnership' do
		context 'with a valid partnership' do
			it 'puts the partnership on the page to be edited' do
				@user = create(:user_profile)
				sign_in @user
				@old_partner = create(:profile)
				ship = @user.partnerships.create(partner: @old_partner)

				get :edit, params: { partnership_id: ship.to_param }
				expect(assigns[:partnership]).to eq ship
			end
		end

		context 'with invalid partnership' do
			it 'redirects to the partnerships index page' do
				get :edit, session: dummy_user_session, params: { partnership_id: 'random' }
				expect(response).to redirect_to partnerships_path
			end
		end
	end

	describe 'PUT #update' do
		before :each do
			allow(controller).to receive(:check_first_time)
		end

		context 'with a valid uid' do
			it 'updates the partner id on the partnership' do
				@user = create(:user_profile)
				sign_in @user
				@old_partner = create(:profile)
				ship = @user.partnerships.create(partner: @old_partner)

				put :update, params: { partnership_id: ship.to_param, partnership: { uid: dummy_user.uid } }
				ship.reload
				expect(response).to redirect_to ship
				expect(ship.partner_id).to eq dummy_user.id
			end

			it 'deletes the orphaned dummy partner', :run_job_immediately do
				@user = create(:user_profile)
				sign_in @user
				@old_partner = create(:profile)
				ship = @user.partnerships.create(partner: @old_partner)

				put :update, params: { partnership_id: ship.to_param, partnership: { uid: dummy_user.uid } }
				expect { Profile.find(@old_partner.id) }.to raise_error(Mongoid::Errors::DocumentNotFound)
			end
		end
	end
end
