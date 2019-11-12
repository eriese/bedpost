class EncounterWhosController < ApplicationController
	include WhosController

	DUMMY_ID = "dummy"

	def new
		@from_dash = from_dash?
		@partnerships = current_user_profile.partnerships
		@dummy_id = DUMMY_ID
		gon_client_validators({who: {partnership_id: nil}})
	end

	def create
		partner_id = params.require(:who).permit(:partnership_id)[:partnership_id]
		if partner_id == DUMMY_ID
			session[:new_encounter] = true
			redirect_to new_dummy_profile_path
		else
			partner = current_user_profile.partnerships.find(partner_id)
			redirect_to new_partnership_encounter_path(partner)
		end
	rescue Mongoid::Errors::DocumentNotFound
		respond_with_submission_error({partnership_id: :blank}, encounters_who_path)
	end
end
