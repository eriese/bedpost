class ApplicationController < ActionController::Base
	protect_from_forgery
	before_action :require_user

	helper_method :current_user

	def current_user
	  @current_user ||= UserProfile.find(session[:user_id]) if session[:user_id]
	end

	def require_user
		redirect_to login_path(r: request.url) unless current_user
	end

	def require_no_user
		redirect_to params[:r] || user_profile_path if current_user
	end
end
