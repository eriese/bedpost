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

		it 'adds the given partner user profile if there is a UID query parameter' do
			profile = create(:user_profile)

			get :new, params: {uid: profile.uid}, session: dummy_user_session
			expect(assigns(:partnership).partner_id).to eq profile.id
		ensure
			profile.destroy
		end

		it 'gives a blank partnership if no uid is given' do
			get :new, session: dummy_user_session
			expect(assigns(:partnership).partner_id).to be_nil
		end

		it 'puts UID errors on the page if the UID connects to nothing' do
			get :new, params: {uid: "nonsense"}, session: dummy_user_session
			expect(assigns(:partnership).partner_id).to be_nil
			expect(assigns(:partnership).uid).to eq "nonsense"

			msg = I18n.t("mongoid.errors.models.partnership.attributes.uid.bad_key")
			expect(flash[:submission_error]["uid"]).to include msg
			expect(gon['submissionError']["uid"]).to include msg
		end

		it 'does not leave an un-saved partnership on the user' do
			get :new, session: dummy_user_session
			expect(controller.current_user.partnerships.length).to eq 0
			get :new, session: dummy_user_session
			expect(controller.current_user.partnerships.length).to eq 0
		end
	end

	describe 'POST #create' do
		# context
	end
end
