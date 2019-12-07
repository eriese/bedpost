require 'rails_helper'

RSpec.describe TermsController, type: :controller do
	describe 'POST #create' do
		before do
			@terms = TermsOfUse.create(terms: 'terms')
			@user = create(:user_profile)
			sign_in @user
		end

		after do
			cleanup(@user, @terms)
		end

		context 'with acceptance'  do
			it 'sets the user accepted if accepted' do
				post :create, params: {tou: {acceptance: '1'}}
				expect(@user.reload).to be_tou_accepted
			end

			it 'redirects to root' do
				post :create, params: {tou: {acceptance: '1'}}
				expect(response).to redirect_to root_path
			end
		end

		context 'without acceptance' do
			it 'does not set the user accepted if not accepted' do
				post :create, params: {tou: {acceptance: '0'}}
				expect(@user.reload).not_to be_tou_accepted
			end

			it 'redirects back to the acceptance page' do
				post :create, params: {tou: {acceptance: '0'}}
				expect(response).to redirect_to terms_path
			end
		end
	end
end
