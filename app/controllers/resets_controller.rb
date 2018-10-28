class ResetsController < ApplicationController
	skip_before_action :require_user
	before_action :require_no_user

	def new
		gon_client_validators({reset: {email: ""}})
	end

	def create
		email = params[:reset][:email]
		user = UserProfile.find_by_email(email)
		SendPasswordResetJob.perform_later(user)
		redirect_to login_path
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to signup_path
	end

	def edit
		email, token_id = valid_or_redirect([:e, :t]) { return }
		@user = UserProfile.find_by_email(email)
		@token = get_valid_token(token_id, @user.id) { return }
		gon_client_validators(@user)
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to login_path
	end

	def update
		token_id = valid_or_redirect(:reset_token) { return }
		user_id, new_pass = params.require(:user_profile).require([:id, :password])
		token = get_valid_token(token_id, user_id) { return }
		user = UserProfile.find(user_id)
		if user.update_only_password(new_pass)
			log_in_user(user)
			token.destroy
			redirect_to user_profile_path
		else
			flash[:error] = user.errors
			redirect_to reset_path(t: token_id, e: user.email)
		end
	end

	private
	def valid_or_redirect(param_names)
		params.require(param_names)
	rescue ActionController::ParameterMissing
		redirect_to login_path
		yield
	end

	def get_valid_token(token_id, user_id)
		token = UserToken.with_user(token_id, user_id)
		if token.nil? || token.token_type != "reset"
			redirect_to login_path
			yield
		else
			return token
		end
	end
end
