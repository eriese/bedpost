class PartnershipWhosController < ApplicationController
	skip_before_action :check_first_time, only: [:new, :create]
	after_action :clear_unsaved, only: [:new, :create]

	def new
		p_id = params[:partnership_id]
		#did the user get to this page from the dashboard?
		@from_dash = request.referer && URI(request.referer).path == root_path
		@partnership = p_id.present? ? current_user_profile.partnerships.find(p_id) : current_user_profile.partnerships.new
		@partnership.uid = flash[:who_attempt][:uid] if flash[:who_attempt].present?
		gon_client_validators(@partnership, {"uid"=> [[:presence]]}, pre_validate: @partnership.uid.present?, serialize_opts: {only: [:uid], methods: [:uid]})
		render p_id.present? ? :edit : :new
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partnerships_path
	end

	def create
		@partnership = current_user_profile.partnerships.new(uid_param)
		if @partnership.valid?
			redirect_to new_partnership_path(p_id: @partnership.partner_id)
		else
			flash_and_respond who_path
		end
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
