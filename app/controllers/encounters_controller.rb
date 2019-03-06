class EncountersController < ApplicationController
	before_action :set_encounter, except: [:index, :new, :create]

	def index
		p_param = params[:partnership_id]
		if p_param
			@encounters = current_user.partnerships.find(p_param).encounters
		else
			@encounters = current_user.encounters
		end
	end

	def show
	end

	def new
		@encounter = Encounter.new
		@partnerships = current_user.partnerships
		@partnership_id = current_user.partnerships.where(id: params[:p]).first
		gon_client_validators({partnership_id: @partnership_id})
		gon_client_validators(@encounter)
	end

	private
	def set_partnership
		@partnership = current_user.partnerships.find(params[:partnership_id])
		return true
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partnerships_path
		return false
	end

	def set_encounter
		@encounter = @partnership.encounters.find(params[:id]) if set_partnership
	rescue Mongoid::Errors::DocumentNotFound
		redirect_back(fallback_location: encounters_path)
	end
end
