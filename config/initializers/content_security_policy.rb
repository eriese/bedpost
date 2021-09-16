# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Rails.application.config.content_security_policy do |policy|
#   policy.default_src :self, :https
#   policy.font_src    :self, :https, :data
#   policy.img_src     :self, :https, :data
#   policy.object_src  :none
#   policy.script_src  :self, :https
#   policy.style_src   :self, :https

#   # Specify URI for violation reports
#   # policy.report_uri "/csp-violation-report-endpoint"
# end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->request do
	if request.env['HTTP_TURBOLINKS_REFERRER'].present?
		request.env['HTTP_X_TURBOLINKS_NONCE']
	else
		SecureRandom.base64(16)
	end
end

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

Rails.application.config.content_security_policy do |policy|
	policy.script_src *[:self, :https, :unsafe_eval]

	policy.script_src *(policy.script_src + ['http://localhost:3035', 'ws://localhost:3035',
																																										'http://localhost:35729']) if Rails.env.development?

	policy.connect_src :self, :https, 'http://localhost:3035', 'ws://localhost:3035',
																				'ws://localhost:35729' if Rails.env.development?
end
