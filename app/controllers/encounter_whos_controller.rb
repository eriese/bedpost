class EncounterWhosController < ApplicationController
	include WhosController
	skip_before_action :check_first_time, only: [:new, :create]

	# the id to indicate that the user has to make a new dummy before creating the encounter
	DUMMY_ID = "dummy"

	def new
		@from_dash = from_dash?
		@partnerships = current_user_profile.partnerships
		@encounter = Encounter.new
		@dummy_id = DUMMY_ID
	end

	def create
		partner_id = params.require(:encounter).permit(:partnership_id)[:partnership_id]
		# if they need to make a dummy
		if partner_id == DUMMY_ID
			# keep in the session that they're making a new encounter so that we can send them into that flow after dummy creation
			session[:new_encounter] = true
			redirect_to new_partnership_path
		else
			# otherwise send them to make an encounter with the partner
			partner = current_user_profile.partnerships.find(partner_id)
			redirect_to new_encounter_path(partnership_id: partner_id)
		end
	rescue Mongoid::Errors::DocumentNotFound
		respond_with_submission_error({partnership_id: :blank}, encounters_who_path)
	end
end
