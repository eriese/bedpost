class BetaController < ApplicationController
	skip_before_action :authenticate_user_profile!
	skip_before_action :check_first_time

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
		binding.pry
		if expected_signature == request.headers["sm-signature"]
			# get data and make token
			head :ok
		else
			head 402
		end
	end
end
