class ApplicationController < ActionController::Base
	protect_from_forgery
	before_action :store_user_location!, if: :storable_location?
	before_action :authenticate_user_profile!
	before_action :check_first_time

	def respond_with_submission_error(error, redirect, status = :unprocessable_entity, adl_json = {})
		flash[:submission_error] = error;
		respond_to do |format|
			format.html {redirect_to redirect}
			format.json {render json: error.deep_merge(adl_json), status: status}
		end
	end

	def gon_client_validators(obj,opts = {}, skip = [], pre_validate: false, serialize_opts: {})
		# TODO consider deep copying if it seems like opts needs to be unedited
		validators = opts
		g_validators = validators
		g_obj = obj
		adder_obj = obj

		unless obj.is_a? Hash
			adder = model_validator_mapper(obj, validators, skip)
			adder_obj = obj.as_json serialize_opts.reverse_merge({strip_qs: true})

			g_obj = {obj.model_name.element => adder_obj}
			g_validators = {obj.model_name.element => validators}
		else
			adder = hash_validator_mapper(obj, validators, skip)
		end

		adder_obj.each(&adder)

		gon.form_obj = (gon.form_obj || {}).deep_merge(g_obj)
		gon.validators = (gon.validators || {}).deep_merge(g_validators)

		flash[:submission_error] ||= obj.errors.messages.stringify_keys if obj.respond_to?(:valid?) && pre_validate && !obj.valid?
		gon.submissionError ||= {}
		gon.submissionError.deep_merge!(flash[:submission_error]) if flash[:submission_error]
	end

	private
	def model_validator_mapper(obj, v_hash, skip)
		is_new = obj.new_record?
		Proc.new do |atr, val|
			next if skip.include? atr
			a_vals = obj.class.validators_on(atr)
			next if a_vals.empty?

			v_hash[atr] ||= []
			v_hash[atr] += a_vals.map do |v|
				next if v.kind == :foreign_key
				if on_cond = v.options[:on]
					next unless (is_new && on_cond == :create) || (!is_new && on_cond == :update)
				end
				if if_cond = v.options[:if]
					next unless obj.send(if_cond)
				end

				[v.kind, v.options]
			end
		end
	end

	def hash_validator_mapper(obj, v_hash, skip)
		Proc.new do |atr, val|
			next if skip.include? atr
			if val.is_a? Hash
				v_hash[atr] ||= {}
				o_adder = hash_validator_mapper(val, v_hash[atr], skip)
				val.each(&o_adder)
			else
				v_hash[atr] = (v_hash[atr] || []) << [:presence, {}]
			end
		end
	end

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
  	return unless user_profile_signed_in?

  	redirect_path =
	  	# if the user hasn't completed their profile, make them do it
	  	if !current_user_profile.set_up?
				edit_user_profile_registration_path
			# if the user hasn't taken any actions in the app yet, take them to the first time page
			elsif current_user_profile.first_time?
				first_time_path
			end

  	redirect_to redirect_path unless redirect_path.nil?
  end
end
