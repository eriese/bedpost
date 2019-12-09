class TermsController < ApplicationController
	skip_before_action :check_first_time
	def new
		@terms = Terms.newest_of_type(:tou)
		@is_accepted = current_user_profile.tou_accepted?
	end

	def create
		if params.require(:tou).permit(:acceptance)[:acceptance] == '1'
			if current_user_profile.update_attribute(:tou, Date.today)
				redirect_to root_path
				return
			end
		end
		respond_with_submission_error({acceptance: [I18n.t('mongoid.errors.models.user_profile.attributes.tou.acceptance')]}, terms_path)
	end
end
