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
		@token = BetaToken.create(email: to_address)
		@signup_url = Rails.application.routes.url_helpers.new_user_profile_registration_url
		mail(to: to_address, subject: "Welcome to BedPost Beta!")
	end
end
