class StaticController < ApplicationController
	def static_or_404
		view_name = params.require(:static).split('/')[-1].delete('.')
		if lookup_context.exists?("#{view_name}.html.erb", ['static'])
			render template: lookup_context.find("#{view_name}.html.erb", ['static'])
		else
			redirect_to root_path
		end
	end
end
