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

	describe 'GET #show' do
		it 'returns json {has_tour: true} if the page has a tour that the user has already seen' do
			@user.tour("page")
			get :show, params: {id: "page"}
			expect(response.body).to eq({has_tour: true}.to_json)
		end

		it 'returns a json representation of the tour if the page has a tour that the user has not seen' do
			get :show, params: {id: "page"}
			expect(response.body).to eq true.to_json
		end

		it 'returns json {has_tour: false} if the page has no tour' do
			allow(controller).to receive(:tour_exists?) {false}
			get :show, params: {id: "page"}
			expect(response.body).to eq({has_tour: false}.to_json)
		end
	end

	describe 'PUT/PATCH #update' do
		it 'adds the page to the pages the user has toured' do
			allow(controller).to receive(:tour_exists?) {true}
			put :update, params: {id: "page"}
			@user.reload
			expect(@user).to have_toured("page")
		end

		it 'always returns a 204' do
			@user.tour("page")
			patch :update, params: {id: "page"}
			expect(response).to have_http_status(204)
		end
	end
end
