class FirstTimesController < ApplicationController
	before_action :require_first_time, only: [:index]
	skip_before_action :check_first_time

	def index
	end

	def show
		page = params[:id]
		if current_user_profile.has_toured?(page)
			render json: {has_tour: true}
		elsif tour = tour_exists?(page)
			render json: tour
		else
			render json: {has_tour: false}
		end
	end

	def update
		page = params[:id]
		current_user_profile.tour(page) if tour_exists?(page)
	end

	def require_first_time
		redirect_to root_path unless current_user_profile.first_time?
	end

	def tour_exists?(page)
		Tour.find_cached(page, field: :page_name)
	end
end
