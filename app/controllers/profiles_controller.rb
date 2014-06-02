class ProfilesController < ApplicationController
  skip_before_filter :require_login, only: [:new, :create]
  def index
    if session[:user_id]
      redirect_to "/profiles/#{session[:user_id]}"
    else
      redirect_to "/login"
    end
  end
  def new
    @profile = Profile.new
    @pronouns = PRONOUNS.map { |pronoun| pronoun[:subject] }
  end
  def create
    @user = Profile.new(params[:profile])
    @user.uid = SecureRandom.uuid.slice(0,8)
    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path(@user)
    else
      redirect_to new_profile_path
    end
  end
  def show
    @partners = @user.partners
    @encounters = @user.encounters.order("took_place DESC")
    @diseases = DISEASES
  end
  def edit
    @profile = @user
    @pronouns = PRONOUNS.map { |pronoun| pronoun[:subject] }
  end
  def update
    if @user.update_attributes(params[:profile])
      redirect_to profile_path(@user)
    else
      redirect_to edit_profile_path(@user)
    end
  end
  def destroy
    @user.destroy
  end
end
