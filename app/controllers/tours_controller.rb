class ToursController < ApplicationController
	before_action :require_first_time, only: [:index]
	skip_before_action :check_first_time

	def index
	end

	def show
		page = params[:id]
		# if there's a tour for this page
		tour = if tour = Tour.by_page!(page)
			# if the user's already seen it and isn't requesting it again just send true
			if current_user_profile.has_toured?(page) && !params[:force]
				{has_tour: true}
			# if they haven't or they are requesting it again, send the tour
			else
				tour
			end
		else
			# if there is no tour, send false
			{has_tour: false}
		end

		tour = {tour_nodes: [{target: "#nav", content: "blah blah blah"}, {target: "header", content: "and blah blah"}, {target: "#page-content", content: "and scene"}]}

		render json: tour
	end

	def update
		page = params[:id]
		# mark the user as having toured the page if there's a tour
		current_user_profile.tour(page) if Tour.by_page!(page)
	end

	def require_first_time
		# only show this page if it's the user's first time
		redirect_to root_path unless current_user_profile.first_time?
	end
end
