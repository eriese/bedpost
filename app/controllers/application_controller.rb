class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :require_login

  private
  def require_login
    unless session[:user_id]
      flash[:error] = "You must be logged in to access this section"
      redirect_to "/login" # halts request cycle
    else
      @user = Profile.find(session[:user_id])
    end
  end
end
