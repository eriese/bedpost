require 'rails_helper'

RSpec.describe "Curl", type: :request do
	let(:headers) do
		{ 'ACCEPT' => '*/*' }
	end

	describe 'getting unlocked pages' do
		paths = {
			'/faq' => 'static pages',
			:new_user_profile_password_path => 'original devise pages',
			:root_path => 'root',
			:new_user_profile_session_path => 'overridden devise pages'
		}

		paths[:beta_registration_path] = 'non-restful pages' if ENV['IS_BETA']

		paths.each do |path, type|
			it "returns html for #{type}" do
				req_path = path.is_a?(Symbol) ? send(path) : path
				get req_path, headers: headers
				expect(response.content_type).to eq 'text/html'
			end
		end
	end

	describe 'getting locked pages' do
		it 'redirects to the signup page' do
			get new_encounter_path, headers: headers
			expect(response).to redirect_to new_user_profile_session_path
		end
	end
end
