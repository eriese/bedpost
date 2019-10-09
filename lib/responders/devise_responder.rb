class DeviseResponder < ActionController::Responder
	def to_json
		if !has_errors? && options[:location].present?
			redirect_to options[:location]
		else
			to_format
		end
	end
end
