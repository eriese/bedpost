require 'rails_helper'

RSpec.describe PartnershipsController, type: :controller do
	describe 'GET #index' do
		it "shows all the partnerships the user has" do
			profiles = create_list(:profile, 3)
			profiles.each{|prof| dummy_user.partnerships << build(:partnership, partner: prof)}
			dummy_user.save

			get :index, session: dummy_user_session
			expect(response).to be_successful
			expect(assigns(:partnerships)).to eq dummy_user.partnerships
		ensure
			dummy_user.partnerships.destroy_all
			profiles.each {|prof| prof.destroy}
		end
	end

	describe 'GET #show' do
		it 'shows the partnership' do
			profile = create(:profile)
			dummy_user.partnerships << build(:partnership, partner: profile)
			dummy_user.save
			ship = dummy_user.partnerships.last

			get :show, params: {id: ship.id}, session: dummy_user_session
			expect(assigns(:partnership)).to eq ship
		ensure
			dummy_user.partnerships.destroy_all
			profile.destroy
		end

		it 'redirects to the index page if the requested partnership id does not refer to a partnership belonging to the user' do
			profile = create(:user_profile)
			profile.partnerships << build(:partnership, partner: dummy_user)
			profile.save
			ship = profile.partnerships.last

			get :show, params: {id: ship.id}, session: dummy_user_session
			expect(response).to redirect_to partners_path
		ensure
			profile.destroy
		end
	end

	describe 'GET #new' do
		include_context :gon

		it 'adds the given partner profile if there is a p_id query parameter' do
			profile = create(:profile)

			get :new, params: {p_id: profile.id}, session: dummy_user_session
			expect(assigns(:partnership).partner_id).to eq profile.id
		ensure
			profile.destroy
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
		end

		it 'does not leave an un-saved partnership on the user' do
			get :new, session: dummy_user_session
			expect(controller.current_user.partnerships.length).to eq 0
			get :index, session: dummy_user_session
			expect(assigns(:partnerships).length).to eq 0

		end
	end

	describe 'POST #create' do
		context 'with a valid partnership' do
			it 'saves the partnership to the user if the partnership has a partner_id' do
				user = create(:user_profile)
				partner = create(:profile)
				post :create, session: {user_id: user.id}, params: {partnership: attributes_for(:partnership).merge({partner_id: partner.id})}

				expect(user.reload.partnerships.length).to eq 1

			ensure
				user.destroy
				partner.destroy
			end

			it 'saves the partnership to the user if the partnership has a uid' do
				user = create(:user_profile)
				partner = create(:user_profile)
				post :create, session: {user_id: user.id}, params: {partnership: attributes_for(:partnership).merge({uid: partner.uid})}

				expect(controller.current_user).to eq user
				expect(controller.current_user.partnerships.length).to eq 1
			ensure
				user.destroy
				partner.destroy
			end

			it 'redirects to the show partnership page for the new partnership' do
				user = create(:user_profile)
				partner = create(:user_profile)
				post :create, session: {user_id: user.id}, params: {partnership: attributes_for(:partnership).merge({uid: partner.uid})}

				expect(response).to redirect_to partner_path(user.reload.partnerships.last)

			ensure
				user.destroy
				partner.destroy
			end
		end

		context 'with invalid partnership' do
			it 'reloads the page' do
				user = create(:user_profile)
				post :create, session: {user_id: user.id}, params: {partnership: attributes_for(:partnership)}

				expect(response).to redirect_to new_partner_path
			ensure
				user.destroy
			end

			it 'does not leave an unsaved partnership on the user' do
				user = create(:user_profile)
				post :create, session: {user_id: user.id}, params: {partnership: attributes_for(:partnership)}

				expect(controller.current_user.partnerships.length).to eq 0
			ensure
				user.destroy
			end
		end
	end

	describe 'POST #check_who' do
		it 'does not leave an unsaved partnership on the user' do
			user = create(:user_profile)
			post :check_who, session: {user_id: user.id}, params: {partnership: {uid: "nonsense"}}

			expect(controller.current_user.partnerships.length).to eq 0
		ensure
			user.destroy
		end

		context 'with a valid uid' do
			it 'forwards to the create partnership page with the partner id of the given user' do
				user = create(:user_profile)
				partner = create(:user_profile)
				post :check_who, session: {user_id: user.id}, params: {partnership: {uid: partner.uid}}

				expect(response).to redirect_to new_partner_path(p_id: partner.id)
			ensure
				user.destroy
				partner.destroy
			end
		end
	end
end
