class UserProfilesController < ApplicationController
	def new
		@user_profile = UserProfile.new
	end
	def create
		@user_profile = UserProfile.new(user_params)
		if @user_profile.save
			session[:user_id] = @user_profile.id
			redirect_to user_profile_path
		else
			redirect_to "/"
		end
	end
	def show
	end

	private def user_params
		params.require(:user_profile).permit(:name, :email, :password)
	end
end
