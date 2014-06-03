class EncountersController < ApplicationController
  before_filter :check_encounter, :except => [:index, :new, :create]
  def index
    @encounters = Encounter.where({user_id: session[:user_id]})
    @partners = @user.partners
  end
  def new
    @partner = Profile.find(params[:partner_id])
    @encounter = @user.encounters.new
    @contact = @encounter.contacts.new
    @instruments = INSTRUMENTS
  end
  def create
    @encounter = @user.encounters.new(params[:encounter])
    partner_id = params[:encounter][:partner_id]
    if @encounter.save
      redirect_to encounter_path(@encounter)
    else
      redirect_to new_encounter_path
      params[:partner_id] = partner_id
    end
  end
  def show
    @contacts = @encounter.contacts
  end
  def edit
    @contacts = @encounter.contacts.new
    @instruments = INSTRUMENTS
  end
  def update
    @encounter.contacts.destroy_all
    if @encounter.update_attributes(params[:encounter])
      params[:encounter][:contacts_attributes].each do |key, value|
        if value[:partner_instrument] == "0"
          Contact.find(value[:id]).destroy
        end
      end
      redirect_to encounter_path(@encounter)
    else
      redirect_to edit_encounter_path(@encounter)
    end
  end
  def destroy
    @encounter = Encounter.find(params[:id])
    @encounter.destroy
  end
  private
  def check_encounter
    @encounter = Encounter.find(params[:id])
    if @encounter.user != @user
      redirect_to encounters_path
    else
      @partner = @encounter.partner
      @pronoun = PRONOUNS.find{|p_set| p_set[:subject] == @partner.pronoun}
    end
  end
end
