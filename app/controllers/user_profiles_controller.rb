class UserProfilesController < ApplicationController
	skip_before_action :require_user, only: [:new, :create]
	before_action :require_no_user, only: [:new, :create]

	def new
		@user_profile = UserProfile.new(flash[:profile_attempt])
		gon_client_validators(@user_profile)
	end
	def create
		req_params = user_params
		@user_profile = UserProfile.new(req_params)
		if @user_profile.save
			session[:user_id] = @user_profile.id
			redirect_to edit_user_profile_path
		else
			flash[:profile_attempt] = req_params
			flash[:message] ||= {}
			flash[:message].merge!(@user_profile.errors.messages)
			redirect_to new_user_profile_path
		end
	end
	def show
	end
	def edit
		@user_profile = current_user
	end

	private def user_params
		params.require(:user_profile).permit(:name, :email, :password)
	end
end
