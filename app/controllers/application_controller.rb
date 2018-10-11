class ApplicationController < ActionController::Base
	protect_from_forgery
	before_action :require_user

	helper_method :current_user

	def current_user
	  @current_user ||= UserProfile.find(session[:user_id]) if session[:user_id]
	end

	def gon_client_validators(obj, opts = {}, skip = [])
		# TODO consider deep copying if it seems like opts needs to be unedited
		validators = opts
		add_validator = Proc.new {|atr, validator|
			next if atr == :password_digest
			validators[atr] ||= []
			validators[atr] << validator unless skip.include? atr
		}
		unless obj.is_a? Hash
			is_new = obj.new_record?
			obj.class.validators.each do |v|
				if !v.options.empty?
					if v.options.has_key?(:on)
						on_cond = v.options[:on]
						next unless (is_new && on_cond == :create) || (!is_new && on_cond == :update)
					end
				end

				v.attributes.each { |a| add_validator.call(a, [v.kind, v.options])}
			end
		else
			obj.keys.each { |key| add_validator.call(key, [:presence])}
		end

		gon.validators = validators
		gon.form_obj = obj
	end

	def require_user
		redirect_to login_path(r: request.url) unless current_user
	end

	def require_no_user
		redirect_to params[:r] || user_profile_path if current_user
	end
end
