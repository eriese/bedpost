class StiTestsController < ApplicationController
	after_action :clear_unsaved, only: [:create]
	before_action :get_test_from_date, only: [:edit, :update, :show, :destroy]

	def index
		@sti_tests = current_user_profile.sti_tests
	end

	def new
		@sti_test = StiTest.new
		gon_sti_test_data
	end

	def create
		new_test = current_user_profile.sti_tests.new(test_params)
		has_tests = new_test.results?
		if has_tests && current_user_profile.save
			redirect_to sti_test_path(new_test)
		else
			respond_with_submission_error(new_test.error_messages, new_sti_test_path)
		end
	end

	def show
	end

	def edit
		gon_sti_test_data
	end

	def update
		if @sti_test.update(test_params)
			flash[:notice] = t(:success, scope: 'sti_tests.update')
			redirect_to(sti_test_path(@sti_test))
		else
			respond_with_submission_error(@sti_test.error_messages, edit_sti_test_path(@sti_test))
		end
	end

	def destroy
		if @sti_test.destroy
			flash[:notice] = t(:success, scope: 'sti_tests.destroy')
			redirect_to(sti_tests_path)
		else
			flash[:error] = t(:error_html, scope: 'sti_tests.destroy')
			redirect_to sti_test_path(@sti_test)
		end
	end

	def unique
		current_date_param = params[:current_tested_on]
		tst = if current_date_param.blank?
									current_user_profile.sti_tests.new
								else
									current_user_profile.sti_tests.with_date(current_date_param)
								end
		tst.tested_on = tested_on_date
		respond_with(tst)
	end

	def tested_on_date
		StiTest.param_to_date(params[:tested_on])
	end

	def test_params
		prms = params.require(:sti_test).permit(:tested_on, results_attributes: [:_id, :tested_for_id, :positive, :_destroy])
		prms[:results_attributes].keep_if { |_i, c| c[:tested_for_id].present? || c[:_destroy] }
		prms
	end

	def gon_sti_test_data
		gon.diagnoses = Diagnosis.list
		gon.dummy = StiTestResult.new
	end

	def clear_unsaved
		current_user_profile.clear_unsaved_sti_tests
	end

	def get_test_from_date
		found_tests = current_user_profile.sti_tests.where(tested_on: tested_on_date)
		if found_tests.exists?
			@sti_test = found_tests.first
		else
			flash[:notice] = I18n.t(:no_sti_tests_with_date, scope: 'helpers.flash')
			redirect_to sti_tests_path
		end
	rescue ArgumentError
		redirect_to sti_tests_path
	end
end
