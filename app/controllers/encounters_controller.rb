class EncountersController < ApplicationController
	after_action :clear_unsaved, only: [:new]
	before_action :set_encounter, except: [:index, :new, :create]

	def index
		p_param = params[:partnership_id]
		if p_param
			@encounters = current_user.partnerships.find(p_param).encounters if set_partnership
		else
			@encounters = current_user.encounters
		end
	end

	def show
	end

	def new
		return unless set_partnership(encounters_who_path)
		@partner = @partnership.partner
		@encounter = @partnership.encounters.new
		gon_encounter_data
		gon_client_validators(@encounter, serialize_opts: {include: [:contacts]})
	end

	def create
		return unless set_partnership(encounters_who_path)
		encounter = @partnership.encounters.new(e_params)
		if encounter.save
			redirect_to partnership_encounter_path(@partnership, encounter)
		else
			respond_with_submission_error(encounter.errors.messages, new_partnership_encounter_path(@partnership))
			clear_unsaved
		end
	end

	def edit
		gon_encounter_data
		gon_client_validators(@encounter)
	end

	def update
		prms = e_params
		if @encounter.update(prms)
			redirect_to partnership_encounter_path(@partnership, @encounter)
		else
			respond_with_submission_error(@encounter.errors.messages, edit_partnership_encounter_path(@partnership, @encounter))
		end
	end

	def destroy
		@encounter.destroy
		redirect_to encounters_path
	end


	private
	def set_partnership(redirect_path = partnerships_path)
		@partnership = current_user.partnerships.find(params[:partnership_id])
		return true
	rescue Mongoid::Errors::DocumentNotFound
		redirect_to redirect_path
		return false
	end

	def set_encounter
		@encounter = @partnership.encounters.find(params[:id]) if set_partnership
		@partner = @partnership.partner
	rescue Mongoid::Errors::DocumentNotFound
		redirect_back(fallback_location: encounters_path)
	end

	def clear_unsaved
		@partnership.clear_unsaved_encounters if @partnership
	end

	def e_params
		c_attrs = [{:barriers => []}, :contact_type, :object_instrument_id, :subject_instrument_id, :position, :_destroy, :subject, :object]
		c_attrs << :_id unless action_name == "create"
		params.require(:encounter).permit(:notes, :fluids, :self_risk, :took_place, contacts_attributes: c_attrs)
	end

	def gon_encounter_data
		gon.encounter_data = {
			partner: @partnership.partner.as_json_private,
			contacts: Contact::ContactType::TYPES,
			user: current_user.as_json_private,
			instruments: Contact::Instrument.hashed_for_partnership(current_user, @partnership.partner),
			possibles: PossibleContact.hashed_for_partnership,
			partnerPronoun: @partnership.partner.pronoun,
			barriers: Contact::BarrierType::TYPES
		}
		gon.dummy = EncounterContact.new
	end
end
