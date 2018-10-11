class ResetsController < ApplicationController
	skip_before_action :require_user
	before_action :require_no_user

	def new
		gon_client_validators({email: ""})
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
		email, token_id = params.require([:e, :t])
		@user = UserProfile.find_by_email(email)
		@token = UserToken.with_user(token_id, @user.id)
		if @token.nil? || @token.token_type != "reset"
			redirect_to login_path
		end
		gon_client_validators(@user)
	rescue Mongoid::Errors::DocumentNotFound, ActionController::ParameterMissing
		redirect_to login_path
	end

	def update
		redirect_to reset_path
	end
end
