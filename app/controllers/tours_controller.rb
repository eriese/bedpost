class ToursController < ApplicationController
	before_action :require_first_time, only: [:index]
	skip_before_action :check_first_time

	def index
	end

	def show
		page = params[:id]
		tour = if tour = Tour.tour_exists?(page)
			if current_user_profile.has_toured?(page) && !params[:force]
				{has_tour: true}
			else
				tour
			end
		else
			{has_tour: false}
		end

		# tour = {tour_nodes: [{target: "#nav", content: "blah blah blah"}]}

		render json: tour
	end

	def update
		page = params[:id]
		current_user_profile.tour(page) if Tour.tour_exists?(page)
	end

	def require_first_time
		redirect_to root_path unless current_user_profile.first_time?
	end
end
