class TrelloController < ApplicationController
	skip_before_action :authenticate_user_profile!
	skip_before_action :check_first_time
	before_action :whitelist_types

	FEEDBACK_TYPES = %w{bug feature}
	def new
	end

	def create
		case @feedback_type
		when :bug
			report = params.require(:bug).permit(:title, :reproduced_times, :expected_behavior, :actual_behavior, :steps, :notes)
			TrelloMailer.delay.bug_report(report)
			flash[:notice] = "Successfully submitted bug report"
		end
		redirect_to feedback_path(feedback_type: @feedback_type)
	end

	def whitelist_types
		redirect_to root_path unless FEEDBACK_TYPES.include? params.require(:feedback_type)
		@feedback_type = case params.require(:feedback_type)
		when 'bug'
			:bug
		when 'feature'
			:feature
		end
	end
end
