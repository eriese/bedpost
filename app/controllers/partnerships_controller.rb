class PartnershipsController < ApplicationController
  before_filter :get_partners
  before_filter :check_partnership, :except => [:index, :new, :create]
  def index
    @at_risk = []
  end
  def new
    @partnership = @user.partnerships.new
  end
  def create
    @partnership = @user.partnerships.new(params[:partnership])
    @partnership.find_partner(params[:uid])
    if @partnership.save
      redirect_to partnership_path(@partnership)
    else
      redirect_to new_partnership_path
    end
  end
  def show
    @encounters = []
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
end
