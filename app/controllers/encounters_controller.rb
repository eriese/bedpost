class EncountersController < ApplicationController
  before :each do
    @user = Profile.find(session[:user_id])
  end
  def index
    @encounters = Encounter.where({user_id: session[:user_id]})
  end
  def new
    @partners = @user.partners
    @encounter = @user.encounters.new
    @contact = @encounter.contacts.new
    @instruments = INSTRUMENTS
  end
  def create
    @encounter = @user.encounters.new(params[:encounter])
    if @encounter.save
      redirect_to encounter_path(@encounter)
    else
      redirect_to new_encounter_path
    end
  end
  def show
    @encounter = Encounter.find(params[:id])
    @contacts = @encounter.contacts
    @partner = @encounter.partner
    @user = @encounter.user
  end
  def edit
    @encounter = Encounter.find(params[:id])
    @partner = @encounter.partner
    @contacts = @encounter.contacts.new
    @instruments = Instrument.all
    @user = User.find(session[:user_id])
  end
  def update

    @partner = Partner.find(params[:partner_id])
    @encounter = Encounter.find(params[:id])
    @encounter.contacts.destroy_all
    if @encounter.update_attributes(params[:encounter])
      params[:encounter][:contacts_attributes].each do |key, value|
        if value[:partner_instrument] == "0"
          Contact.find(value[:id]).destroy
        end
      end
      redirect_to partner_encounter_path(@partner, @encounter)
    else
      redirect_to edit_partner_encounter_path(@partner, @encounter)
    end
  end
  def destroy
    @encounter = Encounter.find(params[:id])
    @encounter.destroy
  end
end
