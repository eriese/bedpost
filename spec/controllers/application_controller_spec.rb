require 'rails_helper'

class ApplicationControllerModel
	include Mongoid::Document

	field :field1
	field :field2

	validates_presence_of :field1, :field2
end

RSpec.describe ApplicationController do
	controller do
		skip_before_action :store_user_location!
		skip_before_action :authenticate_user_profile!

		def show
			head :ok
		end
	end

	context 'before actions' do
		describe '#check_first_time' do
			before :all do
				Terms.create(terms: "some terms", type: :tou)
				Terms.create(terms: "some terms", type: :privacy)
			end

			after :all do
				Terms.destroy_all
			end

			it 'redirects to the term_path for tou if the user has not accepted the terms of use' do
				user = UserProfile.new
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to_not be_terms_accepted :tou
				expect(user).to_not be_terms_accepted :privacy
				expect(user).to_not be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to(term_path(:tou))
			end

			it 'redirects to the edit_user_profile_registration_path if the user has accepted terms of use but is not fully set up' do
				user = UserProfile.new
				allow(user).to receive(:terms_accepted?) {true}
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to be_terms_accepted :tou
				expect(user).to be_terms_accepted :privacy
				expect(user).to_not be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to edit_user_profile_registration_path
			end

			it 'redirects to first_time_index_path if the user has accepted tou and is fully set up but has not completed the tour' do
				user = build_stubbed(:user_profile, first_time: true)
				allow(user).to receive(:terms_accepted?) {true}
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to be_terms_accepted :tou
				expect(user).to be_terms_accepted :privacy
				expect(user).to be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to first_time_path
			end

			it 'does not redirect if the user has accepted the tou, is fully set up, and has completed the tour' do
				user = build_stubbed(:user_profile, first_time: false)
				allow(user).to receive(:terms_accepted?) {true}
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(response).to have_http_status(200)
			end
		end
	end
end
