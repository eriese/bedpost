class TermsController < ApplicationController
	skip_before_action :check_first_time
	def show
		term_type = params[:id].intern
		@terms = Terms.newest_of_type(params[:id])
		@is_accepted = current_user_profile.terms_accepted?(term_type)
		@new_terms = !@is_accepted && current_user_profile.terms && current_user_profile[term_type]
	end

	def update
		term_type = params[:id]
		term_params = params.require(:terms).permit(:acceptance, :opt_in)
		if term_params[:acceptance] == 'true'
			if current_user_profile.accept_terms(term_type, term_params[:opt_in])
				redirect_to root_path
				return
			end
		end
		respond_with_submission_error({acceptance: [I18n.t('mongoid.errors.models.user_profile.attributes.tou.acceptance')]}, term_path(term_type))
	end
end
