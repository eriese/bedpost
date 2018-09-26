class SessionsController < ApplicationController
	def new
	end

	def create
		email = params[:session][:email]
    @user = UserProfile.find_by(email: email)
    password = params[:session][:password]
    if @user && @user.authenticate(password)
      session[:user_id] = @user.id
      redirect_to user_profile_path
    else
      redirect_to 'login'
    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to '/'
  end
end
