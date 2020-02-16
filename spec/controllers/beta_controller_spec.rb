if ENV['IS_BETA']
	require 'rails_helper'

	RSpec.describe BetaController, type: :controller do
		around do |example|
			example.run
			BetaToken.destroy_all
		end

		describe 'POST #create_google' do
			it 'returns head with no content' do
				form_id = Rails.application.credentials.dig(:google_forms, :form_id)
				email = 'RanDOm@Email.com'
				post :create_google, format: :json, params: { payload: { form_id: form_id, email: email, name: 'name' } }
				expect(response).to have_http_status(:ok)
				expect(response.body).to be_empty
			end

			it 'makes a token with a downcased version of the email', :run_job_immediately do
				form_id = Rails.application.credentials.dig(:google_forms, :form_id)
				email = 'RanDOm@Email.com'
				expect { post :create_google, format: :json, params: { payload: { form_id: form_id, email: email, name: 'name' } } }.to change(BetaToken, :count).by(1)
				expect(BetaToken.last.email).to eq email.downcase
			end
		end
	end
end
