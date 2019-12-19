class ToursController < ApplicationController
	before_action :require_first_time, only: [:index]
	skip_before_action :check_first_time
	skip_before_action :authenticate_user_profile!, only: [:show]

	def index
		@num_partnerships = current_user_profile.partnerships.count
		@has_partnerships = @num_partnerships > 0
		@first_partner = current_user_profile.partnerships.first
	end

	def create
		current_user_profile.update({first_time: false})
		redirect_to root_path
	end

	def show
		page = params[:id]
		first_time = !user_profile_signed_in? || current_user_profile.first_time
		# if there's a tour for this page
		tour = if tour = Tour.by_page!(page, first_time)
			# if the user's already seen it and isn't requesting it again just send true
			if current_user_profile.has_toured?(page, tour.fte_only) && params[:force] != 'true'
				{has_tour: true}
			# if they haven't or they are requesting it again, send the tour
			else
				tour
			end
		else
			# if there is no tour, send false
			{has_tour: false}
		end

		# tour = {tour_nodes: [{target: "#nav", content: "blah blah blah"}, {target: "header", content: "and blah blah"}, {target: "#page-content", content: "and scene"}]}

		render json: tour
	end

	def update
		return true unless user_profile_signed_in?
		page = params[:id]
		if tour = Tour.by_page!(page)
			# mark the user as having toured the page if there's a tour
			current_user_profile.tour(page, tour.fte_only)
		end
	end

	def require_first_time
		# only show this page if it's the user's first time
		redirect_to root_path unless current_user_profile.first_time?
	end
end
