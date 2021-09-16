# Preview all emails at http://localhost:3000/rails/mailers/registration
class RegistrationMailerPreview < ActionMailer::Preview
	def confirmation
		@user = UserProfile.first
		RegistrationMailer.confirmation(@user.id)
	end

	def soft_removal
		RegistrationMailer.removal('adfljhdf8347ljkahf', 'email@email.com', 'Enoch', true)
	end

	def hard_removal
		RegistrationMailer.removal('adfljhdf8347ljkahf', 'email@email.com', 'Enoch', false)
	end
end
