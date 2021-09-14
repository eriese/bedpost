class ApplicationMailer < ActionMailer::Base
	helper MailerHelper
	default from: 'support@bedpost.me'
	layout 'mailer'
end
