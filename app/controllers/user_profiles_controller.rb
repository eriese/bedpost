class UserProfilesController < ProfilesController
	skip_before_action :require_user, only: [:new, :create]
	before_action :require_no_user, only: [:new, :create]

	def new
		@profile = UserProfile.new(flash[:profile_attempt])
		gon_client_validators(@profile)
	end
	def create
		req_params = user_params
		@user_profile = UserProfile.new(req_params)
		if @user_profile.save
			session[:user_id] = @user_profile.id
			redirect_to edit_user_profile_path
		else
			flash[:profile_attempt] = req_params
			respond_with_submission_error(@user_profile.errors.messages, signup_path)
		end
	end

	private
		def user_params
			params.require(:user_profile).permit(:name, :email, :password)
		end
		def profile_params
			super + [:email, :password, :uid]
		end
		def param_name
			:user_profile
		end
		def set_profile
			@profile = current_user
		end
		def edit_path
			edit_user_profile_path
		end
		def show_path
			root_path
		end
end
