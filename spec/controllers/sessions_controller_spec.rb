require 'rails_helper'

RSpec.describe SessionsController, type: :controller do

	describe "GET #new" do
		it "redirects to user profile page if user is already logged in" do
			get :new, session: dummy_user_session
			expect(response).to redirect_to user_profile_path
		end

		it "redirects to the page in the r param if the user is already logged in" do
			get :new, session: dummy_user_session, params: {r: "/"}
			expect(response).to redirect_to "/"
		end
	end

	describe "POST #create" do
		def make_post(password="invalid", adl_params={})
			def_params = {session: {email: dummy_user.email, password: password}}
			params = def_params.deep_merge(adl_params)
			post :create, params: params
		end

		context "when password is invalid" do
			it "redirects back to the page login page" do
				make_post
				expect(response).to redirect_to(login_path)
			end

			it "keeps the same email address" do
				make_post
				expect(flash[:email]).to eq dummy_user.email
			end

			it "gives a message that the email or password is wrong" do
				make_post
				expect(flash[:submission_error][:form_error]).to eq "oops, wrong email or password"
			end
		end

		context "when password is valid" do
			it "sets the user to the session" do
				password = attributes_for(:user_profile)[:password];
				make_post(password)

				expect(response).to redirect_to user_profile_path
				expect(controller.current_user).to eq dummy_user
			end

			it "can find the user by email using case-insensitive search" do
				password = attributes_for(:user_profile)[:password];
				up_email = dummy_user.email.upcase
				post :create, params: {session: {email: up_email, password: password}}

				expect(controller.current_user).to eq dummy_user
			end

			context "when the user was redirected from another page" do
				it "redirects the user back to that page after login" do
					password = attributes_for(:user_profile)[:password];
					routed_from = request.base_url + "/profiles"

					make_post(password, {session: {r: "/profiles"}})

					expect(response).to redirect_to "/profiles"
				end
			end
		end
	end

	describe "DELETE #destroy" do
		it "logs the user out" do
			delete :destroy, session: dummy_user_session
			expect(controller.current_user).to be nil
		end

		it "redirects to '/'" do
			delete :destroy, session: dummy_user_session
			expect(response).to redirect_to "/"
		end
	end
end
