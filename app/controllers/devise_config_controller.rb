require "responders/devise_responder"
class DeviseConfigController < ApplicationController
	self.responder = DeviseResponder
	respond_to :html, :json

	def is_flashing_format?
		true
	end

	def after_sign_out_path_for(resource_or_scope)
		scope = Devise::Mapping.find_scope!(resource_or_scope)
		router_name = Devise.mappings[scope].router_name
		context = router_name ? send(router_name) : self
		context.respond_to?(:new_session_path) ? context.new_session_path(scope) : context.respond_to?(:root_path) ? context.root_path : "/"
	end
end
