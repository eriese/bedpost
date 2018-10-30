class SessionsController < ApplicationController
	skip_before_action :require_user, only: [:new, :create]
  before_action :require_no_user, only: [:new, :create]

	def new
		@url = params[:r]
    gon_client_validators({session: {email: flash[:email], password: "", r: @url}}, {}, [:r])
	end

	def create
		email = params[:session][:email]
    if email.empty?
      respond_with_submission_error({email: "please enter an email address"}, login_path(r: params[:session][:r]))
      return
    end
    @user = UserProfile.find_by_email(email)
    password = params[:session][:password]
    if @user && @user.authenticate(password)
      log_in_user(@user)
      redirect_to params[:session][:r] || user_profile_path
    else
      #keep the entered email address, but clear the password
      flash[:email] = email
      respond_with_submission_error({form_error: "oops, wrong email or password"}, login_path(r: params[:session][:r]))
    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end
end
