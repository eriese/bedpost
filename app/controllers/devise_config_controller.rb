require "responders/devise_responder"
class DeviseConfigController < ApplicationController
	self.responder = DeviseResponder
	respond_to :json, :html

	def is_flashing_format?
		true
	end
end
