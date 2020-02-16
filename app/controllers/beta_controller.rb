class BetaController < ApplicationController
	skip_before_action :authenticate_user_profile!
	skip_before_action :check_first_time

	respond_to :json

	def index
		head :ok
	end

	def create
		digest = OpenSSL::Digest::SHA1.new
		secret = Rails.application.credentials.dig(:survey_monkey, :secret)
		key = request.headers['sm-apikey']
		hmac = OpenSSL::HMAC.new("#{key}&#{secret}", digest)
		hmac << request.raw_post
		expected_signature = Base64.encode64(hmac.digest).strip
		if expected_signature == request.headers["sm-signature"]
			req_params = JSON.parse(request.raw_post).to_h.with_indifferent_access
			if req_params[:event_type] == 'response_completed'
				Rails.logger.warn('response webhook properly received')
				SendBetaInviteJob.perform_later(req_params[:resources][:survey_id], req_params[:resources][:respondent_id])
			end
			head :ok
		else
			Rails.logger.warn('Something is wrong with the webook')
			head :unauthorized
		end
	end

	def create_google
		google_params = params.require(:payload).permit(:form_id, :email, :name)
		expected_form_id = Rails.application.credentials.dig(:google_forms, :form_id)
		if google_params[:form_id] != expected_form_id
			Rails.logger.warn "google forms webhook submission from incorrect form id: #{google_params[:form_id]}"
			head :unauthorized
		else
			email = google_params[:email].downcase
			BetaMailer.delay.beta_invite(email, google_params[:name])
			Rails.logger.warn('google forms response webhook properly received')
			head :ok
		end
	end
end
