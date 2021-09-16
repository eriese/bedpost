class PartnershipWhosController < ApplicationController
	include WhosController
	skip_before_action :check_first_time, only: [:check]
	after_action :clear_unsaved, only: [:check]

	respond_to :json

	def edit
		@partnership = current_user_profile.partnerships.find(params.require(:partnership_id))
		@partnership.uid = flash[:who_attempt][:uid] if flash[:who_attempt].present?
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partnerships_path
	end

	def update
		partnership = current_user_profile.partnerships.find(params[:partnership_id])
		if partnership.update(uid_param)
			redirect_to partnership_path(partnership)
		else
			flash_and_respond partnership_who_path(partnership)
		end
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partnerships_path
	end

	def unique
		ship_id = params[:id]
		ship = ship_id.present? ? current_user_profile.partnerships.find(ship_id) : current_user_profile.partnerships.new
		ship.assign_attributes(uid: params.require(:uid))
		respond_with(ship)
	end

	private

	def clear_unsaved
		current_user_profile.clear_unsaved_partnerships
	end

	def uid_param
		@uid_param ||= params.require(:partnership).permit(:uid)
	end

	def flash_and_respond(path)
		flash[:who_attempt] = uid_param
		respond_with_submission_error(@partnership.errors.messages, path)
	end
end
