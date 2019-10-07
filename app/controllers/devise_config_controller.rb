class DeviseConfigController < ApplicationController
	def render *args
		gon_client_validators(resource)
		super
	end
end
