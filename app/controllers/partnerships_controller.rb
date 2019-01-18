class PartnershipsController < ApplicationController
	after_action :clear_unsaved, only: [:new, :check_who, :who]

	def index
		@partnerships = current_user.partnerships
	end

	def show
		@partnership = current_user.partnerships.find(params[:id])
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partners_path
	end

	def new
		@partnership = current_user.partnerships.new(partner_id: params[:p_id])

		unless @partnership.partner_id.present? && @partnership.valid?
			flash[:submission_error] = {"form_error" => @partnership.errors.messages[:partner]}
			flash[:who_attempt] = {partner_id: params[:p_id]}
			redirect_to who_path
		end
		gon_client_validators(@partnership)
	end

	def create
		ship_params = params.require(:partnership).permit(:nickname, :familiarity, :exclusivity, :communication, :partner_id, :uid)

		partnership = current_user.partnerships.new(ship_params)
		if partnership.save
			redirect_to partner_path(partnership)
		else
			clear_unsaved
			respond_with_submission_error(partnership.errors.messages, new_partner_path)
		end
	end

	def who
		@partnership = current_user.partnerships.new(flash[:who_attempt])
		gon_client_validators(@partnership, pre_validate: true)
	end

	def check_who
		uid_param = params.require(:partnership).permit(:uid)
		partnership = current_user.partnerships.new(uid_param)
		if partnership.valid?
			redirect_to new_partner_path(p_id: partnership.partner_id)
		else
			flash[:who_attempt] = uid_param
			respond_with_submission_error(partnership.errors.messages, who_path)
		end
	end

	private
	def clear_unsaved
		current_user.clear_unsaved_partnerships
	end
end
