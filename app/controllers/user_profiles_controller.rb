class UserProfilesController < ProfilesController
	before_action :check_first_time

	protected

	def set_profile
		@profile = current_user_profile
	end
end
