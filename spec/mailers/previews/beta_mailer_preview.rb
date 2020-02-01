# Preview all emails at http://localhost:3000/rails/mailers/trello_mailer
class BetaMailerPreview < ActionMailer::Preview
	def bug_report
		report = {
			title: "A bug has appeared!",
			reproduced_times: 3,
			expected_behavior: "nothing",
			actual_behavior: "something",
			steps: "some steps",
			notes: ""
		}

		BetaMailer.bug_report(report)
	end

	def beta_invite
		BetaMailer.beta_invite "enoch.riese@gmail.com", "Enoch"
	end
end
