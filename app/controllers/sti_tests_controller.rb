class StiTestsController < ApplicationController
	after_action :clear_unsaved, only: [:create]

	def new
		gon_sti_test_data
	end

	def create
		test_params = params.require(:sti_tests).permit(tests_for: [:tested_on, :tested_for_id, :positive, :_destroy])
		num_tests = 0
		test_params[:tests_for].each do |_i, t|
			if t[:tested_for_id].present?
				current_user_profile.sti_tests.new(t)
				num_tests += 1
			end
		end
		if num_tests.positive? && current_user_profile.save
			redirect_to sti_test_path(current_user_profile.sti_tests.last)
		else
			err_key = num_tests.positive? ? :vague : :incomplete
			errors = I18n.t(err_key, scope: 'errors.messages')
			respond_with_submission_error({ form_error: errors }, new_sti_test_path)
		end
	end

	def show
	end

	def gon_sti_test_data
		gon.diagnoses = Diagnosis.list
		gon.dummy = StiTest.new
	end

	def clear_unsaved
		current_user_profile.clear_unsaved_sti_tests
	end
end
