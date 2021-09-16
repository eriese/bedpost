class DeviseFailure < Devise::FailureApp
	def http_auth_body
		return super unless request_format == :json

		{ errors: { form_error: i18n_message } }.to_json
	end
end
