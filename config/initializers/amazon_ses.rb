ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
	:access_key_id     => Rails.env.production? ? Rails.application.credentials.aws!.dig(:ses, :access_key_id) : Rails.application.credentials.dig(:aws, :ses, :access_key_id),
	:secret_access_key => Rails.env.production? ? Rails.application.credentials.aws!.dig(:ses, :secret_access_key) : Rails.application.credentials.dig(:aws, :ses, :secret_access_key)
