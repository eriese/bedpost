require 'rails_helper'

RSpec.describe PartnershipsController, type: :controller do
	describe 'GET #index' do
		after :each do
			dummy_user.partnerships.destroy_all
		end

		it "shows all the partnerships the user has" do
			profiles = create_list(:profile, 3)
			profiles.each{|prof| dummy_user.partnerships << build(:partnership, partner: prof)}
			dummy_user.save

			get :index, session: dummy_user_session
			expect(response).to be_successful
			expect(assigns(:partnerships)).to eq dummy_user.partnerships
		end
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

			get :show, params: {id: @ship.id}, session: dummy_user_session
			expect(assigns(:partnership)).to eq @ship
		end

		it 'redirects to the index page if the requested partnership id does not refer to a partnership belonging to the user' do
			@profile = create(:user_profile)
			@profile.partnerships << build(:partnership, partner: dummy_user)
			@profile.save
			ship = @profile.partnerships.last

			get :show, params: {id: ship.id}, session: dummy_user_session
			expect(response).to redirect_to partnerships_path
		end
	end

	describe 'GET #new' do
		include_context :gon
		after :each do
			cleanup(@profile)
		end

		it 'adds the given partner profile if there is a p_id query parameter' do
			@profile = create(:profile)

			get :new, params: {p_id: @profile.id}, session: dummy_user_session
			expect(assigns(:partnership).partner_id).to eq @profile.id
		end

		it 'redirects to the who page if no partner id is given' do
			get :new, session: dummy_user_session
			expect(response).to redirect_to who_path
		end

		it 'puts partner errors on the who page if the partner id connects to nothing' do
			get :new, params: {p_id: "nonsense"}, session: dummy_user_session
			expect(assigns(:partnership).partner_id).to eq "nonsense"
			expect(assigns(:partnership).uid).to be nil

			msg = I18n.t("mongoid.errors.models.partnership.attributes.partner.blank", attribute: "Partner", default: [:"mongoid.errors.messages.blank", :"errors.messages.blank"])
			expect(flash[:submission_error]["form_error"]).to include msg
			expect(gon['submissionError']['form_error']).to include msg
		end

		it 'does not leave an un-saved partnership on the user' do
			get :new, session: dummy_user_session
			expect(controller.current_user.partnerships.length).to eq 0
			get :index, session: dummy_user_session
			expect(assigns(:partnerships).length).to eq 0
		end
	end

	describe 'POST #create' do
		after :each do
			cleanup(@user, @partner)
		end

		context 'with a valid partnership' do
			it 'saves the partnership to the user if the partnership has a partner_id' do
				@user = create(:user_profile)
				@partner = create(:profile)
				post :create, session: {user_id: @user.id}, params: {partnership: attributes_for(:partnership).merge({partner_id: @partner.id})}

				expect(@user.reload.partnerships.length).to eq 1
			end

			it 'saves the partnership to the user if the partnership has a uid' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				post :create, session: {user_id: @user.id}, params: {partnership: attributes_for(:partnership).merge({uid: @partner.uid})}

				expect(controller.current_user).to eq @user
				expect(controller.current_user.partnerships.length).to eq 1
			end

			it 'redirects to the show partnership page for the new partnership' do
				@user = create(:user_profile)
				@partner = create(:user_profile)
				post :create, session: {user_id: @user.id}, params: {partnership: attributes_for(:partnership).merge({uid: @partner.uid})}

				expect(response).to redirect_to @user.reload.partnerships.last
			end
		end

		context 'with invalid partnership' do
			it 'reloads the page' do
				@user = create(:user_profile)
				post :create, session: {user_id: @user.id}, params: {partnership: attributes_for(:partnership)}

				expect(response).to redirect_to new_partnership_path
			end

			it 'does not leave an unsaved partnership on the user' do
				@user = create(:user_profile)
				post :create, session: {user_id: @user.id}, params: {partnership: attributes_for(:partnership)}

				expect(controller.current_user.partnerships.length).to eq 0
			end
		end
	end

	describe 'GET #edit' do
		after :each do
			cleanup(@user, @partner)
		end

		it 'loads the edit form for the partnership' do
			@user = create(:user_profile)
			@partner = create(:profile)
			ship = @user.partnerships.create(partner: @partner)

			get :edit, session: {user_id: @user.id}, params: {id: ship.id}
			expect(assigns(:partnership)).to eq ship
		end

		it 'redirects to the partnership index page if the partnership does not exist' do
			get :edit, session: dummy_user_session, params: {id: "nonsense"}
			expect(request).to redirect_to partnerships_path
		end
	end

	describe 'POST #create' do
		after :each do
			cleanup(@user, @partner)
		end

		context 'with valid params' do
			it 'updates the partnership' do
				@user = create(:user_profile)
				@partner = create(:profile)
				ship = @user.partnerships.create(partner: @partner)

				new_name = "from camp"
				post :update, session: {user_id: @user.id}, params: {id: ship.id, partnership: {nickname: new_name}}

				ship.reload
				expect(ship.nickname).to eq new_name
			end
		end

		context 'with invalid params' do
			it 'responds with the error' do
				@user = create(:user_profile)
				ship = @user.partnerships.create(partner: dummy_user)

				post :update, session: {user_id: @user.id}, params: {id: ship.id, partnership: {familiarity: 11}}
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
			ship = @user.partnerships.create(partner: dummy_user)

			delete :destroy, params: {id: ship.to_param}, session: {user_id: @user.id}
			expect(@user.reload.partnerships.count).to eq 0
		end

		it 'redirects to the partnerships index page' do
			@user = create(:user_profile)
			ship = @user.partnerships.create(partner: dummy_user)

			delete :destroy, params: {id: ship.to_param}, session: {user_id: @user.id}
			expect(response).to redirect_to partnerships_path
		end
	end
end
