class TrelloMailer < ApplicationMailer
	self.delivery_method = :ses
	TO_EMAIL = 'support@bedpost.me'

	def bug_report(report)
		@report = report
		mail(to: TO_EMAIL, subject: @report[:title])
	end
end
