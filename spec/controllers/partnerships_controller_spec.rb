require 'rails_helper'

RSpec.describe PartnershipsController, type: :controller do
	before :each do |example|
		allow(controller).to receive(:check_first_time) unless example.metadata[:no_skip]
	end

	describe 'GET #show' do
		after :each do
			cleanup(@ship, @profile)
		end

		it 'shows the partnership' do
			profile = create(:profile)
			dummy_user.partnerships << build(:partnership, partner: profile)
			dummy_user.save
			@ship = dummy_user.partnerships.last

			get :show, params: { id: @ship.id }, session: dummy_user_session
			expect(assigns(:partnership)).to eq @ship
		end

		it 'redirects to the index page if the requested partnership id does not refer to a partnership belonging to the user' do
			@profile = create(:user_profile)
			@profile.partnerships << build(:partnership, partner: dummy_user)
			@profile.save
			ship = @profile.partnerships.last

			get :show, params: { id: ship.id }, session: dummy_user_session
			expect(response).to redirect_to partnerships_path
		end
	end

	describe 'GET #new', no_skip: true do
		after :each do
			cleanup(@profile)
		end

		it 'does not leave an un-saved partnership on the user', no_skip: false do
			@profile = create(:user_profile)
			sign_in(@profile)
			@profile.partnerships << build(:partnership, partner: dummy_user)
			get :new
			expect(controller.current_user_profile.partnerships.length).to be 1

			get :index
			expect(controller.current_user_profile.partnerships.length).to be 1
		end

		it 'adds the encounter flow tag to the session if there is an encounter parameter' do
			@profile = create(:user_profile)
			sign_in(@profile)
			get :new, params: { enc: 'true' }
			expect(session[:new_encounter]).to be true
		end
	end

	describe 'POST #create', no_skip: true do
		before :each do
			@user = create(:user_profile)
			sign_in @user
		end

		after :each do
			cleanup(@user, @partner)
		end

		context 'with a valid partnership' do
			it 'saves the partnership to the user if the partnership has a uid' do
				@partner = create(:user_profile)
				post :create, params: { partnership: attributes_for(:partnership, uid: @partner.uid) }

				expect(controller.current_user_profile).to eq @user
				expect(controller.current_user_profile.partnerships.length).to eq 1
			end

			it 'saves the partnership to the user if the partnership has no uid, but has params for a partner profile' do
				ship_attributes = attributes_for(:partnership, partner_attributes: attributes_for(:profile))
				post :create, params: { partnership: ship_attributes }
				@partner = Profile.last
				@user.reload

				expect(@user.partnerships.length).to eq 1
				expect(@user.partnerships.last.partner).to eq @partner
			end

			it 'chooses a valid uid over creating a new user' do
				@partner = create(:user_profile)
				ship_attributes = attributes_for(:partnership, partner_attributes: attributes_for(:profile), uid: @partner.uid)
				expect { post :create, params: { partnership: ship_attributes } }.not_to change(Profile, :count)

				@user.reload
				expect(@user.partnerships.length).to eq 1
				expect(@user.partnerships.last.partner).to eq @partner
			end

			describe 'redirects' do
				it 'redirects to the show partnership page for the new partnership if it is not part of an encounter flow' do
					@partner = create(:user_profile)
					post :create, params: { partnership: attributes_for(:partnership, uid: @partner.uid) }

					expect(response).to redirect_to @user.reload.partnerships.last
				end

				it 'redirects to the new encounter form for the partnerhip if it is part of an encounter flow' do
					@partner = create(:user_profile)
					post :create, session: { new_encounter: true },
																			params: { partnership: attributes_for(:partnership, uid: @partner.uid) }

					ship = @user.reload.partnerships.last
					expect(response).to redirect_to new_encounter_path(partnership_id: ship.id)
				end
			end
		end

		context 'with invalid partnership' do
			it 'reloads the page' do
				post :create, session: { user_id: @user.id }, params: { partnership: attributes_for(:partnership) }

				expect(response).to redirect_to new_partnership_path
			end

			it 'does not leave an unsaved partnership on the user' do
				post :create, session: { user_id: @user.id }, params: { partnership: attributes_for(:partnership) }

				expect(controller.current_user_profile.partnerships.length).to eq 0
			end
		end
	end

	describe 'GET #edit' do
		after :each do
			cleanup(@user, @partner)
		end

		it 'loads the edit form for the partnership' do
			@user = create(:user_profile)
			sign_in @user
			@partner = create(:profile)
			ship = @user.partnerships.create(partner: @partner)

			get :edit, session: { user_id: @user.id }, params: { id: ship.id }
			expect(assigns(:partnership)).to eq ship
		end

		it 'redirects to the partnership index page if the partnership does not exist' do
			get :edit, session: dummy_user_session, params: { id: 'nonsense' }
			expect(request).to redirect_to partnerships_path
		end
	end

	describe 'POST #update' do
		after :each do
			cleanup(@user, @partner)
		end

		context 'with valid params' do
			it 'updates the partnership' do
				@user = create(:user_profile)
				sign_in @user
				@partner = create(:profile)
				ship = @user.partnerships.create(partner: @partner)

				new_name = 'from camp'
				post :update, session: { user_id: @user.id }, params: { id: ship.id, partnership: { nickname: new_name } }

				ship.reload
				expect(ship.nickname).to eq new_name
			end
		end

		context 'with invalid params' do
			it 'responds with the error' do
				@user = create(:user_profile)
				sign_in @user
				ship = @user.partnerships.create(partner: dummy_user)

				post :update, session: { user_id: @user.id }, params: { id: ship.id, partnership: { familiarity: 11 } }
				expect(response).to redirect_to edit_partnership_path(ship)
				expect(flash[:submission_error]).to have_key(:familiarity)
			end
		end
	end

	describe 'DELETE #destroy' do
		after :each do
			cleanup(@user)
		end

		it 'destroys the requested parnership' do
			@user = create(:user_profile)
			sign_in @user
			ship = @user.partnerships.create(partner: dummy_user)

			delete :destroy, params: { id: ship.to_param }, session: { user_id: @user.id }
			expect(@user.reload.partnerships.count).to eq 0
		end

		it 'redirects to the partnerships index page' do
			@user = create(:user_profile)
			sign_in @user
			ship = @user.partnerships.create(partner: dummy_user)

			delete :destroy, params: { id: ship.to_param }, session: { user_id: @user.id }
			expect(response).to redirect_to partnerships_path
		end
	end
end
