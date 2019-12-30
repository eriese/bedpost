class TrelloController < ApplicationController
	skip_before_action :authenticate_user_profile!
	skip_before_action :check_first_time
	before_action :whitelist_types

	FEEDBACK_TYPES = %w{bug feature}
	def new

	end

	def create
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
