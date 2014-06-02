class WelcomeController < ApplicationController
  def index
    if session[:user_id]
      redirect_to profile_path(User.find(session[:user_id]))
    end
  end
  def create
    @user = Profile.where(email: params[:email]).first.try(:authenticate, params[:password])
    if @user
      session[:user_id] = @user.id
      redirect_to "/profiles"
    else
      redirect_to "/login"
    end
  end
  def destroy
    session[:user_id] = nil
    redirect_to "/login"
  end
end
