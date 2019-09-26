class UserProfilesController < ProfilesController
	skip_before_action :require_user, only: [:new, :create]
	before_action :require_no_user, only: [:new, :create]

	def new
		@profile = UserProfile.new(flash[:profile_attempt])
		gon_client_validators(@profile, serialize_opts: edit_validator_serialize_opts)
	end
	def create
		req_pms = user_params
		@user_profile = UserProfile.new(req_pms)
		if @user_profile.save
			session[:user_id] = @user_profile.id
			redirect_to edit_user_profile_path
		else
			flash[:profile_attempt] = req_pms
			respond_with_submission_error(@user_profile.errors.messages, signup_path)
		end
	end


	protected
	def user_params
		params.require(:user_profile).permit(:name, :email, :password, :password_confirmation)
	end
	def profile_params
		super + [:uid, :email, :old_password, :password, :password_confirmation]
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
	def edit_validator_serialize_opts
		{methods: [:password, :password_confirmation]}
	end
	def edit_validator_opts
		{old_password: [[]]}
	end
end
