class SessionsController < ApplicationController
	skip_before_action :require_user, only: [:new, :create]
  before_action :require_no_user, only: [:new, :create]

	def new
		@url = params[:r]
    gon_client_validators({session: {email: flash[:email], password: "", r: @url}}, {}, [:r])
    gon.formError = flash[:form_error]
	end

	def create
		email = params[:session][:email]
    if email.empty?
      flash[:error] = "please enter an email address"
      redirect_to login_path(r: params[:session][:r])
      return
    end
    @user = UserProfile.find_by_email(email)
    password = params[:session][:password]
    if @user && @user.authenticate(password)
      log_in_user(@user)
      redirect_to params[:session][:r] || user_profile_path
    else
    	flash[:form_error] = "oops, wrong email or password"
      #keep the entered email address, but clear the password
      flash[:email] = email
      respond_to do |format|
        format.html { redirect_to login_path(r: params[:session][:r]) }
        format.json { render json: {formError: flash[:form_error]}, status: :unprocessable_entity}
      end
    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end
end
