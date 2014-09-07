class PartnershipsController < ApplicationController
  before_filter :get_partners
  before_filter :check_possible, :only => [:new, :create]
  before_filter :check_partnership, :except => [:index, :new, :create, :landing]
  def index
    diseases = DISEASES.sort{|d| d[:gestation_max]}
    @at_risk = []
    @partnerships.each do |partnership|
      if partnership.at_risk?(diseases.last[:name])
        @at_risk << partnership
      end
    end
  end
  def landing
  end
  def new
    @partnership = @user.partnerships.new
    @uid = flash[:uid] || params[:uid]
  end
  def create
    @partnership = @user.partnerships.new(params[:partnership])
    @partnership.find_partner(params[:uid])
    if @partnership.save
      redirect_to partnership_path(@partnership)
    else
      flash[:message] = @partnership.errors.messages
      redirect_to new_partnership_path
    end
  end
  def show
    @encounters = @partnership.encounters
  end
  def edit
  end
  def update
    if !params[:uid].blank?
      @partnership.find_partner(params[:uid])
    end
    if @partnership.update_attributes(params[:partnership])
      redirect_to partnership_path(@partnership)
    else
      redirect_to edit_partnership_path(@partnership)
    end
  end
  def destroy
    @partnership.destroy
  end
  private
  def get_partners
    @partnerships = @user.partnerships
    @partners = @user.partners
  end
  def check_partnership
    @partnership = Partnership.find(params[:id])
    if @partnership.user != @user
      redirect_to partnerships_path
    else
      @partner = @partnership.partner
    end
  end
  def check_possible
    if params[:partnership]
      redirect = new_partnership_path
      check_uid = params[:partnership][:uid]
    elsif params[:uid]
      redirect = "/partnerships/landing"
      check_uid = params[:uid]
    end
    if check_uid
      partner = Profile.where({uid: check_uid})
      if partner.empty?
        flash[:message] = {message: ["There is no user with that uid"]}
        redirect_to redirect
      elsif @user.uid == check_uid
        flash[:message] = {message: ["That is your own uid"]}
        redirect_to redirect
      elsif !Partnership.new({user_id: @user.id, partner_id: partner.first.id}).valid?
        tester = Partnership.new({user_id: @user.id, partner_id: partner.first.id})
        tester.valid?
        flash[:message] = tester.errors.messages
        redirect_to redirect
      end
    end
  end
end
