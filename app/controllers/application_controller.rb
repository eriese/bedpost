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
		respond_to do |format|
			format.html {flash[:submission_error] = error; redirect_to redirect}
			format.json {render json: error.deep_merge(adl_json), status: status}
		end
	end

	def gon_client_validators(obj, opts = {}, skip = [])
		# TODO consider deep copying if it seems like opts needs to be unedited
		validators = opts
		adder = validator_adder(obj, validators, skip)
		unless obj.is_a? Hash
			is_new = obj.new_record?
			obj.class.validators.each do |v|
				if !v.options.empty?
					if v.options.has_key?(:on)
						on_cond = v.options[:on]
						next unless (is_new && on_cond == :create) || (!is_new && on_cond == :update)
					end
				end

				v.attributes.each { |a| adder.call(a, [v.kind, v.options])}
			end
			gon.form_obj = {obj.model_name.element => obj}
			gon.validators = {obj.model_name.element => validators}
		else
			obj.keys.each { |key| adder.call(key, [:presence])}
			gon.form_obj = obj
			gon.validators = validators
		end
		gon.submissionError = flash[:submission_error]
	end

	private
	def validator_adder(obj, v_hash, skip = [])
		Proc.new do |atr, validator|
			unless atr == :password_digest || skip.include?(atr)
				if obj[atr].is_a? Hash
					v_hash[atr] ||= {}
					o_adder = validator_adder(obj[atr], v_hash[atr], skip)
					obj[atr].keys.each{|key| o_adder.call(key, validator)}
				else
					v_hash[atr] ||= []
					v_hash[atr] << validator
				end
			end
		end
	end
end
