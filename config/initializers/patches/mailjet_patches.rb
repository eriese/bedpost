class Mailjet::APIMailer
	def deliver!(mail, opts = {})
		options = HashWithIndifferentAccess.new(opts)

		# Mailjet Send API does not support full from. Splitting the from field into two: name and email address
		mail[:from] ||= Mailjet.config.default_from if Mailjet.config.default_from

		# add `@connection_options` in `options` only if not exist yet (values in `options` prime)
		options.reverse_merge!(@connection_options)

		# add `@version` in options if set
		options[:version] = @version if @version

		# `options[:version]` primes on global config
		version = options[:version] || Mailjet.config.api_version

		if (version == 'v3.1')
			Mailjet::Send.create({
				Messages: [setContentV3_1(mail)],
				SandboxMode: !Rails.env.production?
			}, options)
		else
			Mailjet::Send.create(setContentV3_0(mail), options)
		end
	end
end
