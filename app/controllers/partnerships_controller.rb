class PartnershipsController < ApplicationController
	after_action :clear_unsaved, only: [:new]
	before_action :set_partnership, only: [:show, :edit, :update, :destroy]

	def index
		@partnerships = current_user.partnerships
	end

	def show
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
		ship_params = params.require(:partnership).permit(Partnership::LEVEL_FIELDS + [:nickname, :partner_id, :uid])

		partnership = current_user.partnerships.new(ship_params)
		if partnership.save
			redirect_to partnership
		else
			respond_with_submission_error(partnership.errors.messages, new_partnership_path)
			clear_unsaved
		end
	end

	def edit
		gon_client_validators(@partnership)
	end

	def update
		ship_params = params.require(:partnership).permit(Partnership::LEVEL_FIELDS + [:nickname])
		if @partnership.update(ship_params)
			redirect_to @partnership
		else
			respond_with_submission_error(@partnership.errors.messages, edit_partnership_path(@partnership))
		end
	end

	def destroy
		@partnership.destroy
		redirect_to partnerships_path
	end

	private
	def clear_unsaved
		current_user.clear_unsaved_partnerships
	end

	def set_partnership
		@partnership = current_user.partnerships.find(params[:id])
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partnerships_path
	end

end