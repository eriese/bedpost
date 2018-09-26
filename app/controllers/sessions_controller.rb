class SessionsController < ApplicationController
	skip_before_action :require_user, only: [:new, :create]
	def new
		@url = params[:r]
	end

	def create
		email = params[:session][:email].downcase
    @user = UserProfile.find_by(email: email)
    password = params[:session][:password]
    if @user && @user.authenticate(password)
      session[:user_id] = @user.id
      redirect_to params[:r] || user_profile_path
    else
    	flash[:error] = "oops, wrong password"
      redirect_to login_path
    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end
end
