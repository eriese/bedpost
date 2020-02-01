class SendBetaInviteJob < ApplicationJob
	queue_as :default

	NAME_INDEX = 1
	EMAIL_INDEX = 0

	def perform(survey_id, response_id)
		url = "https://api.surveymonkey.net/v3/surveys/#{survey_id}/responses/#{response_id}/details"
		bearer_token = Rails.application.credentials.dig(:survey_monkey, :access_token)
		response = HTTP.auth("Bearer #{bearer_token}").get(url)
		resp_json = response.parse.with_indifferent_access
		questions = resp_json[:pages][1][:questions]
		email = questions[EMAIL_INDEX][:answers][0][:text]
		name = questions[NAME_INDEX][:answers][0][:text]
		BetaMailer.beta_invite(email, name).deliver_now
	end
end
