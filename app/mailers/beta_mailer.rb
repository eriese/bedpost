class BetaMailer < ApplicationMailer
	self.delivery_method = :ses
	FEATURE_EMAIL = Rails.application.credentials.dig(:trello, :features) || 'support@bedpost.me'
	BUG_EMAIL = Rails.application.credentials.dig(:trello, :bugs) || 'support@bedpost.me'

	def bug_report(report, screenshots=nil)
		@report = report
		screenshots.each {|k,v| attachments[k] = v} unless screenshots.nil?
		mail(to: BUG_EMAIL, subject: @report[:title])
	end

	def feature_request(request)
		@request = request
		mail(to: FEATURE_EMAIL, subject: @request[:title])
	end

	def beta_invite(to_address, name)
		@name = name
		to_address.downcase!
		@token = BetaToken.find_or_create_by(email: to_address)
		urls = Rails.application.routes.url_helpers
		@signup_url = ENV['IS_BETA'] ? urls.beta_registration_url : urls.new_user_profile_registration_url
		@reason = 'You are receiving this email because you completed our survey to request an invitation to join our beta. If you don\'t want to receive any more communication from us, simply ignore this email and you won\'t hear from us again.'
		mail(to: to_address, subject: 'Welcome to BedPost Beta!')
	end
end
