class ProfilesController < ApplicationController
  def index
    if session[:user_id]
      redirect_to "/profiles/#{session[:user_id]}"
    else
      redirect_to "/login"
    end
  end
  def new
    @profile = Profile.new({uid: SecureRandom.uuid.slice(0,8)})
    @pronouns = PRONOUNS.map { |pronoun| pronoun[:subject] }
  end
  def create
    @user = Profile.new(params[:profile])
    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path(@user)
    else
      redirect_to new_profile_path
    end
  end
  def show
    @user = Profile.find(session[:user_id])
    @partners = @user.partners
    @encounters = @user.encounters.order("took_place DESC")
    @diseases = DISEASES
  end
  def edit
    @user = Profile.find(session[:user_id])
    @pronouns = PRONOUNS
  end
  def update
    @user = User.find(session[:user_id])
    if @user.update_attributes(params[:profile])
      redirect_to profile_path(@user)
    else
      redirect_to edit_profile_path
    end
  end
  def destroy
    @user = Profile.find(session[:user_id])
    @user.destroy
  end
end
