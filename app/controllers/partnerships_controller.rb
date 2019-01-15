class PartnershipsController < ApplicationController
	after_action :refresh_user, only: :new

	def index
		@partnerships = current_user.partnerships
	end

	def show
		@partnership = current_user.partnerships.find(params[:id])
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partners_path
	end

	def new
		@partnership = current_user.partnerships.new

		if params[:p_id]
			@partnership.partner = Profile.find(params[:p_id])
		elsif params[:uid]
			@partnership.uid = params[:uid]
		end

		gon_client_validators(@partnership)
	end

	def refresh_user
		current_user.reload
	end
end
