class UniquenessResponder < ActionController::Responder
	def respond
		if controller.action_name == 'unique'
			if resource && !resource.valid?
				messages = resource.respond_to?(:error_messages) ? resource.error_messages : resource.errors.messages
				controller.render json: messages
			else
				controller.render json: true
			end
		else
			super
		end
	end
end
