class TermsController < ApplicationController
	skip_before_action :check_first_time
	skip_before_action :authenticate_user_profile!
	before_action :validate_type

	def show
		@terms = Terms.newest_of_type(@type_key)
		if user_profile_signed_in?
			@is_accepted = current_user_profile.terms_accepted?(@type_key)
			@new_terms = !@is_accepted && current_user_profile.terms && current_user_profile.terms[@type_key]
		else
			@not_form = true
		end
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

	def validate_type
		@type_key = params.require(:id).intern
		redirect_to(root_path) unless Terms::TYPES.include? @type_key
	end
end
