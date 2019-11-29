require 'rails_helper'

RSpec.describe ToursController, type: :controller do
	before :each do
		@user = create(:user_profile)
		sign_in @user
	end

	after :each do
		cleanup @user, @tour
	end

	describe 'GET #index' do
		it 'redirects to dashboard if the user has already experienced the first time flow' do
			get :index
			expect(response).to redirect_to root_path
		end

		it 'renders index if the user has not experienced the first time flow' do
			@user.update({first_time: true})
			get :index
			expect(response).to render_template :index
		end
	end

	describe 'POST #create' do
		it 'marks the user as having completed the first time flow' do
			post :create
			# TODO update this to false after merging fixes to normalize_blank_values
			expect(@user.reload.first_time?).to be_falsy
		end

		it 'redirects to the dashboard' do
			post :create
			expect(response).to redirect_to root_path
		end
	end

	describe 'GET #show' do
		it 'returns json {has_tour: true} if the page has a tour that the user has already seen' do
			page_name = "page"
			@tour = create(:tour, page_name: page_name)
			@user.tour(page_name)
			get :show, params: {id: page_name}
			expect(response.body).to eq({has_tour: true}.to_json)
		end

		it 'returns a json representation of the tour if the page has a tour that the user has not seen' do
			page_name = "page"
			@tour = create(:tour, page_name: page_name)
			get :show, params: {id: page_name}
			expect(response.body).to eq @tour.to_json
		end

		it 'returns json {has_tour: false} if the page has no tour' do
			get :show, params: {id: "page"}
			expect(response.body).to eq({has_tour: false}.to_json)
		end

		context 'with force: true' do
			it 'returns a json representation of the tour if the page has a tour, regardless of whether the user has seen it' do
				page_name = "page"
				@user.tour(page_name)
				@tour = create(:tour, page_name: page_name)
				get :show, params: {id: page_name, force: true}
				expect(response.body).to eq @tour.to_json
			end

			it 'returns json {has_tour: false} if the page has no tour' do
				get :show, params: {id: "page", force: true}
				expect(response.body).to eq({has_tour: false}.to_json)
			end
		end
	end

	describe 'PUT/PATCH #update' do

		it 'adds the page to the pages the user has toured' do
			page_name = "page"
			@tour = create(:tour, page_name: page_name)
			put :update, params: {id: page_name}
			@user.reload
			expect(@user).to have_toured(page_name)
		end

		it 'always returns a 204' do
			page_name = "page"
			@tour = create(:tour, page_name: page_name)
			@user.tour(page_name)
			patch :update, params: {id: page_name}
			expect(response).to have_http_status(204)
		end

		it 'does not add a non-existent tour to the user' do
			page_name = "page"
			patch :update, params: {id: page_name}
			@user.reload
			expect(@user).to_not have_toured(page_name)
		end
	end
end
