class TermsController < ApplicationController
	skip_before_action :check_first_time
	def show
		term_type = params[:id].intern
		@terms = Terms.newest_of_type(params[:id])
		@is_accepted = current_user_profile.terms_accepted?(term_type)
	end

	def update
		term_type = params[:id]
		if params.require(:terms).permit(:acceptance)[:acceptance] == '1'
			if current_user_profile.accept_terms(term_type)
				redirect_to root_path
				return
			end
		end
		respond_with_submission_error({acceptance: [I18n.t('mongoid.errors.models.user_profile.attributes.tou.acceptance')]}, term_path(term_type))
	end
end
