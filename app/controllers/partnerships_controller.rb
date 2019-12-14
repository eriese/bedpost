class PartnershipsController < ApplicationController
	after_action :clear_unsaved, only: [:new]
	skip_before_action :check_first_time, only: [:new, :create]
	before_action :set_partnership, only: [:show, :edit, :update, :destroy]

	def index
	end

	def show
	end

	def new
		@partnership = current_user_profile.partnerships.new(partner: Profile.new)
	end

	def create
		ship_params_uid = params.require(:partnership).permit(Partnership::LEVEL_FIELDS + [:nickname, :uid])
		ship_params_partner = params.require(:partnership).permit(partner_attributes: [:anus_name, :can_penetrate, :external_name, :internal_name, :name, :pronoun_id])

		partnership = current_user_profile.partnerships.new(ship_params_uid)

		partnership.assign_attributes(ship_params_partner) unless partnership.valid?

		if partnership.save
			# if they were making a new encounter, send them to do that
			redirect_to session.delete(:new_encounter) ? new_partnership_encounter_path(partnership) : partnership_path(partnership)
		else
			respond_with_submission_error(partnership.errors.messages, new_partnership_path)
			clear_unsaved
		end
	end

	def edit
	end

	def update
		ship_params = params.require(:partnership).permit(Partnership::LEVEL_FIELDS + [:nickname])
		if @partnership.update(ship_params)
			redirect_to partnership_path(@partnership)
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
		current_user_profile.clear_unsaved_partnerships
	end

	def set_partnership
		@partnership = current_user_profile.partnerships.find(params[:id])
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to partnerships_path
	end

end
