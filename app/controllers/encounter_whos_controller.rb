class EncounterWhosController < ApplicationController
	def new
		@partnerships = current_user.partnerships
		gon_client_validators({who: {partnership_id: nil}})
	end

	def create
		partner_id = params.require(:who).permit(:partnership_id)[:partnership_id]
		partner = current_user.partnerships.find(partner_id)
		redirect_to new_partnership_encounter_path(partner)
	rescue Mongoid::Errors::DocumentNotFound
		respond_with_submission_error({partnership_id: "Please choose a partner"}, encounters_who_path)
	end
end
