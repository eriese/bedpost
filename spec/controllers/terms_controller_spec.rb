require 'rails_helper'

RSpec.describe TermsController, type: :controller do
	describe 'PUT #update' do
		before do
			@terms = Terms.create(terms: 'terms', type: :tou)
			@user = create(:user_profile)
			sign_in @user
		end

		after do
			cleanup(@user, @terms)
		end

		context 'with acceptance'  do
			it 'sets the user accepted if accepted' do
				put :update, params: {id: :tou, terms: {acceptance: '1'}}
				expect(@user.reload).to be_terms_accepted :tou
			end

			it 'redirects to root' do
				put :update, params: {id: :tou, terms: {acceptance: '1'}}
				expect(response).to redirect_to root_path
			end
		end

		context 'without acceptance' do
			it 'does not set the user accepted if not accepted' do
				put :update, params: {id: :tou, terms: {acceptance: '0'}}
				expect(@user.reload).not_to be_terms_accepted :tou
			end

			it 'redirects back to the acceptance page' do
				put :update, params: {id: :tou, terms: {acceptance: '0'}}
				expect(response).to redirect_to term_path(:tou)
			end
		end
	end
end
