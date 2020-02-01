class ApplicationMailer < ActionMailer::Base
	add_template_helper(MailerHelper)
	default from: 'support@bedpost.me'
	layout 'mailer'
end
