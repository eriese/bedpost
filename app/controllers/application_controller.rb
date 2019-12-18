class ApplicationController < ActionController::Base
	protect_from_forgery
	before_action :store_user_location!, if: :storable_location?
	before_action :authenticate_user_profile!
	before_action :check_first_time

	layout :choose_layout

	def respond_with_submission_error(error, redirect, status = :unprocessable_entity, adl_json = {})
		flash[:submission_error] = error;
		respond_to do |format|
			format.html {redirect_to redirect}
			format.json {render json: {errors: error}.deep_merge(adl_json), status: status}
		end
	end

	private
	# Its important that the location is NOT stored if:
	# - The request method is not GET (non idempotent)
	# - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
	#    infinite redirect loop.
	# - The request is an Ajax request as this can lead to very unexpected behaviour.
	def storable_location?
		request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
	end

	def store_user_location!
		# :user is the scope we are authenticating
		store_location_for(:user_profile, request.fullpath)
	end

	# check if the user has unfinished parts of the first time experience
	def check_first_time
		# only run if a user is signed in and the request is storable
		return unless user_profile_signed_in? && storable_location?

		redirect_path =
			if !current_user_profile.terms_accepted? :tou
				term_path(:tou)
			# if the user hasn't completed their profile, make them do it
			elsif !current_user_profile.terms_accepted? :privacy
				term_path(:privacy)
			elsif !current_user_profile.set_up?
				edit_user_profile_registration_path
			# if the user hasn't taken any actions in the app yet, take them to the first time page
			elsif current_user_profile.first_time?
				first_time_path
			end

		redirect_to redirect_path unless redirect_path.nil?
	end

	# set the layout based on whether there is a user who should be able to access all authorize features
	def choose_layout
		user_profile_signed_in? && !current_user_profile.first_time? ? "authed" : "no_auth"
	end

	def self.responder
		lambda do |controller, resources, options|
			if (controller.action_name == 'unique')
				UniquenessResponder.call(controller, resources, options)
			else
				super.call(controller,resources,options)
			end
		end
	end
end
