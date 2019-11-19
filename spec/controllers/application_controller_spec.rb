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
			it 'redirects to the edit_user_profile_registration_path if the user is not fully set up' do
				user = UserProfile.new
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to_not be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to edit_user_profile_registration_path
			end

			it 'redirects to first_time_index_path if the user is fully set up but has taken no actions' do
				user = build_stubbed(:user_profile)
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(user).to be_set_up
				expect(user).to be_first_time
				expect(response).to redirect_to first_time_path
			end

			it 'does not redirect if the user if fully set up and has taken any actions' do
				user = double("UserProfile", set_up?: true, first_time?: false)
				allow(controller).to receive(:current_user_profile) {user}
				get :show, params: {id: "id"}
				expect(response).to have_http_status(200)
			end
		end
	end
end
