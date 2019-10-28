class FirstTimesController < ApplicationController
	before_action :require_first_time, only: [:index]
	skip_before_action :check_first_time

	def index
	end

	def show
	end

	def update
	end

	def require_first_time
		redirect_to root_path unless current_user_profile.first_time?
	end
end
