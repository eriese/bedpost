class TrelloMailer < ApplicationMailer
	self.delivery_method = :ses
	# FEATURE_EMAIL = Rails.credentials.dig(:trello, :features) || 'support@bedpost.me'
	# BUG_EMAIL = Rails.credentials.dig(:trello, :bugs) || 'support@bedpost.me'
	BUG_EMAIL = 'support@bedpost.me'
	FEATURE_EMAIL = 'support@bedpost.me'

	def bug_report(report)
		@report = report
		mail(to: BUG_EMAIL, subject: @report[:title])
	end

	def feature_request(request)
		@request = request
		mail(to: FEATURE_EMAIL, subject: @request[:title])
	end
end
