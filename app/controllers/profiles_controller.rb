class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /partners/1
  # GET /partners/1.json
  def show
  end

  # GET /partners/new
  def new
    @profile = Profile.new
    gon_client_validators(@profile)
  end

  # GET /partners/1/edit
  def edit
    if @partnership.present? && @profile.is_a?(UserProfile)
      redirect_to @partnership
    else
      gon_client_validators(@profile, edit_validator_opts, serialize_opts: edit_validator_serialize_opts, pre_validate: false)
    end
  end

  # POST /partners
  # POST /partners.json
  def create
    @profile = Profile.new(req_params)
    if @profile.save
      redirect_to new_partnership_path(p_id: @profile.id)
    else
      flash[:profile_attempt] = req_params
      respond_with_submission_error(@profile.errors.messages, new_dummy_profile_path)
    end
  end

  # PATCH/PUT /partners/1
  # PATCH/PUT /partners/1.json
  def update
    if @profile.update(req_params)
      redirect_to show_path, notice: 'Profile was successfully updated.'
    else
      respond_with_submission_error(@profile.errors.messages, edit_path)
    end
  end

  # DELETE /partners/1
  # DELETE /partners/1.json
  def destroy
    @profile.destroy
    respond_to do |format|
      format.html { redirect_to partnerships_url, notice: 'Profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  protected
    def req_params
      ps = params.require(param_name).permit(profile_params)
      ps[:internal_name] = nil if params[param_name][:show_internal] == "false" && @profile && @profile.internal_name.present?
      return ps
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @partnership = current_user.partnerships.find(params[:partnership_id])
      @profile = Profile.find(@partnership.partner_id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      [:internal_name, :external_name, :anus_name, :pronoun_id, :name, :can_penetrate]
    end

    def param_name
      :profile
    end

    def edit_path
      edit_partnership_profile_path(@partnership)
    end

    def show_path
      @partnership
    end

    def edit_validator_serialize_opts
      {}
    end

    def edit_validator_opts
      {}
    end
end
