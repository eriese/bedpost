# Preview all emails at http://localhost:3000/rails/mailers/registration
class RegistrationMailerPreview < ActionMailer::Preview

	def confirmation
		@user = UserProfile.first
		RegistrationMailer.confirmation(@user.id)
	end

end
