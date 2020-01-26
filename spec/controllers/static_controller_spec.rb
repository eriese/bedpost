require 'rails_helper'

RSpec.describe StaticController, type: :controller do
	describe 'get #static_or_404' do
		context 'with a valid page' do
			it 'renders the view' do
				get :static_or_404, params: {static: 'faq'}
				expect(response).to render_template 'faq.html.erb'
			end
		end

		context 'with a malicious page' do
			it 'redirects to root with raw html' do
				get :static_or_404, params: {static: '<div></div>'}
				expect(response).to redirect_to root_path
			end

			it 'redirects to root with a request to a resource outside of the static scope' do
				get :static_or_404, params: {static: 'application'}
				expect(response).to redirect_to root_path
			end

			it 'redirects to root with a request for a js resource' do
				get :static_or_404, params: {static: 'application.js'}
				expect(response).to redirect_to root_path
			end

			it 'redirects to root with a request for embedded ruby' do
				get :static_or_404, params: {static: '<%= `ls` %>'}
			end
		end

		context 'with an invalid page' do
			it 'redirects to root' do
				get :static_or_404, params: {static: 'about_me'}
				expect(response).to redirect_to root_path
			end
		end
	end
end
