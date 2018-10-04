class ApplicationController < ActionController::Base
	protect_from_forgery
	before_action :require_user

	helper_method :current_user

	def current_user
	  @current_user ||= UserProfile.find(session[:user_id]) if session[:user_id]
	end

	def gon_client_validators(obj)
		validators = {};
		is_new = obj.new_record?
		obj.class.validators.each do |v|
			if !v.options.empty?
				if v.options.has_key?(:on)
					on_cond = v.options[:on]
					next unless (is_new && on_cond == :create) || (!is_new && on_cond == :update)
				end
			end

			v.attributes.each do |a|
				next if a == :password_digest
				validators[a] ||= []
				validators[a] << [v.kind, v.options]
			end
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
