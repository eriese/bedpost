# frozen_string_literal: true

class UserProfiles::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  def new
    super do |resource|
      gon_client_validators(resource, serialize_opts: {methods: [:password, :password_confirmation]})
      @gon = true
    end
  end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  def edit
    gon_client_validators(resource, {current_password: [[]]}, pre_validate: false, serialize_opts: {methods: [:password, :password_confirmation]})
    gon_client_validators({account_delete: {current_password: ""}})
    @gon = true
    super
  end

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

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :uid, :internal_name, :external_name, :anus_name, :pronoun_id, :name, :can_penetrate, :opt_in])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    edit_user_profile_registration_path
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
