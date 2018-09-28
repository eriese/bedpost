require 'rails_helper'

RSpec.describe UserProfilesController, type: :controller do
	describe "GET #new" do
		it "redirects to user profile page if user is already logged in" do
			get :new, session: dummy_user_session
			expect(response).to redirect_to user_profile_path
		end
	end

	pending "POST #create" do
		context "with valid params" do
			it "creates a new UserProfile" do
			end
		end
	end
end
