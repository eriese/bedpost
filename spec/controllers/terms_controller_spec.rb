require 'rails_helper'

RSpec.describe TermsController, type: :controller do
	describe 'PUT #update' do
		before do
			@terms = Terms.create(terms: 'terms', type: :tou)
			@user = create(:user_profile_new)
			sign_in @user
		end

		after do
			cleanup(@user, @terms)
		end

		context 'with acceptance'  do
			it 'sets the user accepted if accepted' do
				put :update, params: {id: :tou, terms: {acceptance: true}}
				expect(@user.reload).to be_terms_accepted :tou
			end

			it 'redirects to root' do
				put :update, params: {id: :tou, terms: {acceptance: true}}
				expect(response).to redirect_to root_path
			end
		end

		context 'without acceptance' do
			it 'does not set the user accepted if not accepted' do
				put :update, params: {id: :tou, terms: {acceptance: false}}
				expect(@user.reload).not_to be_terms_accepted :tou
			end

			it 'redirects back to the acceptance page' do
				put :update, params: {id: :tou, terms: {acceptance: false }}
				expect(response).to redirect_to term_path(:tou)
			end
		end

		context 'with opt_in' do
			it 'sets opt_in if the user accepts the terms and opts in' do
				put :update, params: {id: :tou, terms: {acceptance: true, opt_in: true}}
				expect(@user.reload.opt_in).to be true
			end

			it 'sets opt_in if the user accepts the terms and opts out' do
				@user.update_attribute(:opt_in, true)
				put :update, params: {id: :tou, terms: {acceptance: true, opt_in: false}}
				expect(@user.reload.opt_in).to be false
			end

			it 'does not set opt_in if the user does not accept the terms' do
				@user.update_attribute(:opt_in, true)
				put :update, params: {id: :tou, terms: {acceptance: false, opt_in: false}}
				expect(@user.reload.opt_in).to be true
			end

			it 'does not change the opt_in value if no opt_in value is submitted' do
				@user.update_attribute(:opt_in, true)
				put :update, params: {id: :tou, terms: {acceptance: true}}
				expect(@user.reload.opt_in).to be true
			end
		end
	end
end
