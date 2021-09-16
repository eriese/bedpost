credentials = {}

case Rails.env
when 'production'
	credentials = Rails.application.credentials.aws!
when 'development'
	credentials = Rails.application.credentials.dig(:aws) || {}
end

access_key_id = credentials.dig(:ses, :access_key_id)
secret_key_id = credentials.dig(:ses, :secret_access_key)

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
																																							:access_key_id => access_key_id,
																																							:secret_access_key => secret_key_id
