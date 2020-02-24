class TrelloController < ApplicationController
	prepend_before_action :skip_timeout, only: [:new]
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
			screenshots = params.require(:bug).permit(screenshots: [])[:screenshots]
			attachments = screenshots.nil? ? {} : Hash[screenshots.map { |s| [s.original_filename, s.tempfile.read] }]
			BetaMailer.delay(queue: 'mailers').bug_report(report, attachments)
			flash[:notice] = "Successfully submitted bug report"
		when :feature
			report = params.require(:feature).permit(:title, :what, :why)
			BetaMailer.delay(queue: 'mailers').feature_request(report)
			flash[:notice] = "Successfully submitted feature request"
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
