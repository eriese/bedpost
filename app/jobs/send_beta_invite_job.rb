class SendBetaInviteJob < ApplicationJob
	queue_as :default

	NAME_INDEX = 2
	EMAIL_INDEX = 1

	DUMMY_DATA = {
		"pages": [
			{
				"id": "108361237",
				"questions": [
					{
						"id": "402954322",
						"answers": [
							{
								"choice_id": "2678634131"
							}
						]
					},
					{
						"id": "402961848",
						"answers": [
							{
								"tag_data": [],
								"text": "enoch.riese+11@gmail.com"
							}
						]
					},
					{
						"id": "402971164",
						"answers": [
							{
								"tag_data": [],
								"text": "Enoch"
							}
						]
					}
				]
			}
		]
	}

	def perform(survey_id, response_id)
		url = "https://api.surveymonkey.net/v3/surveys/#{survey_id}/responses/#{response_id}/details"
		bearer_token = Rails.application.credentials.dig(:survey_monkey, :access_token)
		# response = HTTP.auth("Bearer #{bearer_token}").get(url)
		# response_json = response.parse.with_indifferent_access
		# response_json = DUMMY_DATA.with_indifferent_access
		questions = response_json[:pages][0][:questions]
		email = questions[EMAIL_INDEX][:answers][0][:text]
		name = questions[NAME_INDEX][:answers][0][:text]
		BetaMailer.beta_invite(email, name).deliver_now
	end
end
