class StaticController < ApplicationController
	skip_before_action :store_user_location!
	skip_before_action :authenticate_user_profile!
	skip_before_action :check_first_time

	def static_or_404
		view_name = params.require(:static).split('/')[-1].delete('.')
		if lookup_context.exists?("#{view_name}", ['static'])
			render template: lookup_context.find("#{view_name}", ['static'])
		else
			redirect_to root_path
		end
	end
end
