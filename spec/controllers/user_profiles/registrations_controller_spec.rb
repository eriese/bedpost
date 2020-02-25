require 'rails_helper'

RSpec.describe UserProfiles::RegistrationsController, type: :controller do
	before :each do
		@request.env['devise.mapping'] = Devise.mappings[:user_profile]
	end

	describe "GET #new" do
		it "redirects to user profile page if user is already logged in" do
			get :new, session: dummy_user_session
			expect(response).to redirect_to root_path
		end
	end

	describe 'POST #create' do
		if ENV['IS_BETA']
			context 'with a beta token' do
				around do |example|
					@token = BetaToken.find_or_create_by(email: 'email@email.com')
					example.run
					cleanup @token, UserProfile.where(email: @token.email).first
				end

				def do_post(email: nil, token: nil)
					user_attrs = attributes_for(:user_profile)
					post :create, format: :json, params: {
						user_profile: {
							email: email || @token.email,
							token: token || @token.token,
							password: user_attrs[:password],
							password_confirmation: user_attrs[:password],
							name: user_attrs[:name]
						}
					}
				end

				context 'with a correct email and token' do
					it 'registers with a correct email and token in lowercase' do
						expect { do_post }.to change(UserProfile, :count).by(1)
					end

					it 'registers with a correct email in random cases' do
						expect { do_post email: 'EmaIL@emAIl.com' }.to change(UserProfile, :count).by(1)
					end

					it 'registers with a correct token in uppercase' do
						expect { do_post token: @token.token.upcase }.to change(UserProfile, :count).by(1)
					end

					it 'destroys the token' do
						expect { do_post }.to change(BetaToken, :count).by(-1)
					end

					it 'redirects back to the beta signup page' do
						user_attrs = attributes_for(:user_profile)
						post :create, params: {
							user_profile: {
								token: '',
								email: '',
								password: user_attrs[:password],
								password_confirmation: user_attrs[:password],
								name: user_attrs[:name]
							}
						}
						expect(response).to render_template :new_beta
					end
				end

				context 'with incorrect email or token' do
					it 'responds with unprocessable entity with a token that does not exist' do
						do_post token: 'random'
						expect(response).to have_http_status(:unprocessable_entity)
					end

					it 'responds with unprocessable entity with an email that is not associated with the token' do
						do_post email: 'random@email.com'
						expect(response).to have_http_status(:unprocessable_entity)
					end

					it 'returns a form error' do
						do_post email: 'random@email.com'
						response_json = JSON.parse(response.body)
						expect(response_json['errors']).to have_key('form_error')
					end
				end
			end
		end

		context 'with valid parameters' do
			def get_valid_params
				{ user_profile: @user_attributes }
			end

			def get_new_prof(params)
				UserProfile.find_by(email: params[:user_profile][:email].downcase)
			end

			before do
				@user_attributes = attributes_for(:user_profile)
				if ENV['IS_BETA']
					@token = BetaToken.create(email: @user_attributes[:email])
					@user_attributes[:token] = @token.token
				end
			end
			after :each do
				cleanup @prof, @token
			end

			it "creates a new UserProfile" do
				valid_params = get_valid_params

				expect{post :create, params: valid_params}.to change(UserProfile, :count).by(1)
				@prof = get_new_prof(valid_params)
				expect(@prof).to_not be_nil
			end

			it "saves the submitted name, email, and password" do
				valid_params = get_valid_params
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)
				expect(@prof.pronoun).to be_nil
				expect(@prof.name).to eq valid_params[:user_profile][:name]
				expect(@prof.email).to eq valid_params[:user_profile][:email]
			end

			it "signs the user in" do
				valid_params = get_valid_params
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)

				expect(controller.current_user_profile).to eq @prof
			end

			it "redirects the user to the root path (lets the first time filter decide where they go next)" do
				valid_params = get_valid_params
				post :create, params: valid_params
				@prof = get_new_prof(valid_params)

				expect(response).to redirect_to root_path
			end
		end
	end

	describe 'PUT #update' do
		before :each do
			@user = create(:user_profile)
			sign_in @user
		end

		after :each do
			cleanup @user
		end

		context 'with valid password' do
			it 'updates the email address' do
				pms = {user_profile: {current_password: attributes_for(:user_profile)[:password], email: "newemail@mail.com"}}
				put :update, params: pms
				expect(@user.reload.email).to eq(pms[:user_profile][:email])
				expect(response).to redirect_to root_path
			end

			it 'updates the password' do
				new_password = "testtest"
				pms = {user_profile: {current_password: attributes_for(:user_profile)[:password], password: new_password, password_confirmation: new_password}}
				put :update, params: pms
				expect(@user.reload.valid_password?(new_password)).to be true
			end
		end

		context 'with invalid password' do
			it 'responds with a submission error' do
				new_password = "testtest"
				pms = {user_profile: {current_password: "invalid", password: new_password, password_confirmation: new_password}}
				put :update, params: pms, format: :json
				expect(response.body).to include("current_password")
			end
		end

		context 'with no password' do
			it 'updates non-protected fields' do
				pms = {user_profile: {external_name: "new name", email: @user.email, password: "", current_password: "", password_confirmation: ""}}
				put :update, params: pms
				expect(@user.reload.external_name).to eq(pms[:user_profile][:external_name])
			end

			it 'responds with a submission error if a protected field is changed' do
				pms = {user_profile: {external_name: "new name", email: "newemail@mail.com", password: "", current_password: "", password_confirmation: ""}}
				put :update, params: pms, format: :json
				expect(response).to have_http_status(422)
			end
		end
	end

	describe 'DELETE #destroy' do
		before :each do
			allow(controller).to receive(:check_first_time)
			@user = create(:user_profile)
			sign_in @user
		end

		after :each do
			cleanup @user
		end

		it 'calls #soft_destroy on the user if the password is correct' do
			expect_any_instance_of(UserProfile).to receive(:soft_destroy)
			delete :destroy, params: {account_delete: {current_password: attributes_for(:user_profile)[:password]}}, format: :json
			expect(response).to_not have_http_status(422)
		end

		it 'returns an error if the password is not correct' do
			delete :destroy, params: {account_delete: {current_password: "wrong"}}, format: :json
			expect(response).to have_http_status(422)
		end
	end
end
