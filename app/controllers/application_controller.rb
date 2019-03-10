class ApplicationController < ActionController::Base
	protect_from_forgery
	before_action :require_user

	helper_method :current_user

	def current_user
	  @current_user ||= UserProfile.find(session[:user_id]) if session[:user_id]
	end

	def log_in_user(user_profile)
		session[:user_id] = user_profile.id
	end

	def require_user
		redirect_to login_path(r: request.url) unless current_user
	end

	def require_no_user
		redirect_to params[:r] || user_profile_path if current_user
	end

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
		# adder = nil
		unless obj.is_a? Hash
			adder = model_validator_mapper(obj, validators, skip)
			adder_obj = obj.serializable_hash serialize_opts.reverse_merge({strip_qs: true})

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
				if on_cond = v.options[:on]
					next unless (is_new && on_cond == :create) || (!is_new && on_cond == :update)
				end

				[v.kind, v.options]
			end
		end
	end

	def hash_validator_mapper(obj, v_hash, skip)
		Proc.new do |atr, val|
			return if skip.include? atr
			if val.is_a? Hash
				v_hash[atr] ||= {}
				o_adder = hash_validator_mapper(val, v_hash[atr], skip)
				val.each(&o_adder)
			else
				v_hash[atr] = (v_hash[atr] || []) << [:presence, {}]
			end
		end
	end
end
