class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /partners
  # GET /partners.json
  def index
    @partners = Profile.all
  end

  # GET /partners/1
  # GET /partners/1.json
  def show
  end

  # GET /partners/new
  def new
    @profile = Profile.new
  end

  # GET /partners/1/edit
  def edit
    gon_client_validators(@profile)
    gon_toggle({internal_name: @profile.has_internal?})
  end

  # POST /partners
  # POST /partners.json
  def create
    @profile = Profile.new(profile_params)

    respond_to do |format|
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
        format.json { render :show, status: :created, location: @profile }
      else
        format.html { render :new }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
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
      format.html { redirect_to partners_url, notice: 'Profile was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def req_params
      ps = params.require(param_name).permit(profile_params)
      ps[:internal_name] = nil if params[param_name][:show_internal] == "0" && @profile.internal_name.present?
      return ps
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = Profile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def profile_params
      [:internal_name, :external_name, :anus_name, :pronoun]
    end

    def param_name
      :profile
    end

    def edit_path
      edit_partner_path(@profile)
    end

    def show_path
      @profile
    end

end
