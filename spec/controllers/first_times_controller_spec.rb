require 'rails_helper'

RSpec.describe FirstTimesController, type: :controller do
	before :each do
		@user = create(:user_profile)
		sign_in @user
	end

	after :each do
		cleanup @user
	end

	describe 'GET #index' do
		it 'redirects to dashboard if the user has already experienced the first time flow' do
			allow_any_instance_of(UserProfile).to receive(:first_time?) {false}
			get :index
			expect(response).to redirect_to root_path
		end

		it 'renders index if the user has not experienced the first time flow' do
			get :index
			expect(response).to render_template :index
		end
	end
end
