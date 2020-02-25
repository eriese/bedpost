# frozen_string_literal: true

class UserProfiles::RegistrationsController < Devise::RegistrationsController
	skip_before_action :check_first_time, except: [:destroy]
	before_action :configure_sign_up_params, only: [:create]
	before_action :configure_account_update_params, only: [:update]

	respond_to :json, except: [:new, :edit]

	# GET /resource/sign_up
	def new_beta
		build_resource
		respond_with resource
	end

	# POST /resource
	def create
		super do |resource|
			RegistrationMailer.delay(queue: 'mailers').confirmation(resource.id.to_s) if resource.persisted?
		end
	end

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
			redirect_to after_sign_out_path_for(resource_name)
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
		return unless ENV['IS_BETA']

		token_params = params.require(resource_name).permit(:email, :token)
		found = true
		begin
			token = BetaToken.find_token(token_params[:token].downcase)
			found = token.email.downcase == token_params[:email].downcase
		rescue Mongoid::Errors::DocumentNotFound
			found = false
		end
		return if found

		build_resource(sign_up_params)
		clean_up_passwords resource
		resource.errors.add(:form_error, "Uh oh! We don't recognize this beta token with your email address")

		respond_with resource
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
