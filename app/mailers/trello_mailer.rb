class TrelloMailer < ApplicationMailer
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
end
