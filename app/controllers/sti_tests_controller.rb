class StiTestsController < ApplicationController
	after_action :clear_unsaved, only: [:create]

	def index
	end

	def new
		@test = StiTest.new
		gon_sti_test_data
	end

	def create
		given_tests = test_params
		given_tests[:results_attributes].keep_if { |_i, c| c[:tested_for_id].present? }
		new_test = current_user_profile.sti_tests.new(given_tests)
		has_tests = new_test.results?
		if has_tests && current_user_profile.save
			redirect_to sti_test_path(new_test)
		else
			errors = if has_tests
				new_test.errors.messages.merge({
					results: new_test.results.map { |r| r.errors.messages }
				})
			else
				{ form_error: I18n.t(:incomplete, scope: 'errors.messages') }
			end
			respond_with_submission_error(errors, new_sti_test_path)
		end
	end

	def show
		tested_on = StiTest.param_to_date(params[:tested_on])
		found_tests = current_user_profile.sti_tests.where(tested_on: tested_on)
		if found_tests.exists?
			@sti_test = found_tests.first
		else
			flash[:notice] = I18n.t(:no_sti_tests_with_date, scope: 'helpers.flash')
			redirect_to sti_tests_path
		end
	rescue ArgumentError
		redirect_to sti_tests_path
	end

	def unique
		current_date_param = params[:current_tested_on]
		tst = if current_date_param.blank?
			current_user_profile.sti_tests.new(tested_on: tested_on_date)
		else
			current_user_profile.sti_tests.with_date(tested_on_date)
		end
		respond_with(tst)
	end

	def tested_on_date
		StiTest.param_to_date(params[:tested_on])
	end

	def test_params
		params.require(:sti_test).permit(:tested_on, results_attributes: [:tested_for_id, :positive])
	end

	def gon_sti_test_data
		gon.diagnoses = Diagnosis.list
		gon.dummy = StiTestResult.new
	end

	def clear_unsaved
		current_user_profile.clear_unsaved_sti_tests
	end
end
