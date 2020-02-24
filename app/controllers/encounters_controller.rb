class EncountersController < ApplicationController
	skip_before_action :check_first_time, only: [:new, :create, :show]
	after_action :clear_unsaved, only: [:new]
	before_action :set_encounter, except: [:index, :new, :create]

	def index
		# the page needs to know whether a specific partner was requested
		@is_partner = params[:partnership_id].present?
		# and whether the user has any partnerships regardless of whether or not those partnerships have encounters
		@has_partners = current_user_profile.partnerships.any?
		# use an aggregation to get all necessary data about partnerships that have encounters
		@partnerships = current_user_profile.partners_with_encounters(params[:partnership_id]).to_a
		@partnerships.each_with_index do |ship, i|
			# add an index
			ship[:index] = i
			# create the display name
			ship[:display] = Partnership.make_display(ship['partner_name'], ship['nickname'])
		end
	end

	def show
		@force = params[:force]
		@partner = @encounter.partnership.partner
		Encounter::RiskCalculator.new(@encounter).track(force: @force)
		respond_to do |format|
			# just send the alternate schedule html if it's a json request
			format.json { render inline: helpers.display_schedule(@encounter) }
			format.html { render :show }
		end
	end

	def new
		given_partnership = params[:partnership_id]
		partnership_id =
			if current_user_profile.partnerships.where(id: given_partnership).exists?
				given_partnership
			elsif current_user_profile.partnerships.count == 1
				current_user_profile.partnerships.first.id
			end

		@encounter = current_user_profile.encounters.new(partnership_id: partnership_id)
		@partnerships = current_user_profile.partners_with_profiles.to_a
		gon_encounter_data
	end

	def create
		encounter = current_user_profile.encounters.new(e_params)
		if encounter.save
			redirect_to encounter_path(encounter)
		else
			respond_with_submission_error(encounter.errors.messages, new_encounter_path)
			clear_unsaved
		end
	end

	def edit
		@partnerships = current_user_profile.partners_with_profiles.to_a
		gon_encounter_data
	end

	def update
		prms = e_params
		# set barriers to an empty array if none were submitted
		prms[:contacts_attributes].each { |i, a| a[:barriers] ||= [] } if prms[:contacts_attributes].present?
		if @encounter.update(prms)
			redirect_to encounter_path(@encounter)
		else
			respond_with_submission_error(@encounter.errors.messages, edit_encounter_path(@encounter))
		end
	end

	def destroy
		@encounter.destroy
		redirect_to encounters_path
	end


	private
	def set_encounter
		@encounter = current_user_profile.encounters.find(params[:id])
		@partnership = @encounter.partnership
	rescue Mongoid::Errors::DocumentNotFound
		redirect_back(fallback_location: encounters_path)
	end

	def clear_unsaved
		current_user_profile.clear_unsaved_encounters
	end

	def e_params
		c_attrs = [{:barriers => []}, :possible_contact_id, :position, :_destroy, :subject, :object]
		c_attrs << :_id unless action_name == "create"
		params.require(:encounter).permit(:notes, :fluids, :self_risk, :took_place, :partnership_id, contacts_attributes: c_attrs)
	end

	def gon_encounter_data
		gon.encounter_data = {
			partners: @partnerships,
			contacts: Contact::ContactType::TYPES,
			user: current_user_profile.as_json_private,
			instruments: Contact::Instrument.as_map,
			possibles: PossibleContact.hashed_for_partnership,
			pronouns: Pronoun.as_map,
			barriers: Contact::BarrierType::TYPES
		}
		gon.dummy = EncounterContact.new
	end
end
