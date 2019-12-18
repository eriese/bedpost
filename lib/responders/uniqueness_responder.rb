class UniquenessResponder < ActionController::Responder
	def respond
		if controller.action_name == 'unique'
			resource.valid?
			if resource.errors.any?
				controller.render json: resource.errors.messages
			else
				controller.render json: true
			end
		else
			super
		end
	end
end
