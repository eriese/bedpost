# frozen_string_literal: true

class UserProfiles::RegistrationsController < Devise::RegistrationsController
	skip_before_action :check_first_time, except: [:destroy]
	before_action :configure_sign_up_params, only: [:create]
	before_action :configure_account_update_params, only: [:update]

	respond_to :json


	# GET /resource/sign_up
	# def new
	#   super do |resource|
	#   end
	# end

	# POST /resource
	# def create
	# 	super
	# end

	# GET /resource/edit
	# def edit
	#   super
	# end

	# PUT /resource
	# def update
	#   super do |resource|

	#   end
	# end

	# DELETE /resource
	def destroy
		pass = params.require(:account_delete).permit(:current_password)[:current_password]
		if resource.destroy_with_password(pass)
			Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
			set_flash_message! :notice, :destroyed
			yield resource if block_given?
			respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
		else
			respond_with resource
		end
	end

	# GET /resource/cancel
	# Forces the session data which is usually expired after sign
	# in to be expired now. This is useful if the user wants to
	# cancel oauth signing in/up in the middle of the process,
	# removing all OAuth session data.
	# def cancel
	#   super
	# end
	#
	def unique
		unique_params = params.permit(:email, :uid)
		profile = user_profile_signed_in? ? current_user_profile : UserProfile.new
		profile.assign_attributes(unique_params)
		respond_with(profile)
	end


	# protected

	# If you have extra params to permit, append them to the sanitizer.
	def configure_sign_up_params
		devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
		if ENV['IS_BETA']
			token_params = params.require(resource_name).permit(:email, :token)
			binding.pry
			unless BetaToken.where(token_params).exists?
				err = {beta_token: ["We don't recognize this beta token with your email address"]}
				respond_with_submission_error(err,  new_registration_path(resource_name))
			end
		end
	end

	# If you have extra params to permit, append them to the sanitizer.
	def configure_account_update_params
		devise_parameter_sanitizer.permit(:account_update, keys: [:email, :uid, :internal_name, :external_name, :anus_name, :pronoun_id, :name, :can_penetrate, :opt_in])
	end

	# The path used after sign up.
	def after_sign_up_path_for(resource)
		root_path
	end

	def update_resource(resource, params)
		if params[:password].present? || params[:password_confirmation].present? || (params[:email].present? && params[:email] != resource.email)
			resource.update_with_password(params)
		else
			resource.update_without_password(params)
		end
	end

	# The path used after sign up for inactive accounts.
	# def after_inactive_sign_up_path_for(resource)
	#   super(resource)
	# end
end
