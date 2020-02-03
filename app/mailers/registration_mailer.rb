class RegistrationMailer < ApplicationMailer
	self.delivery_method = :ses

	def confirmation(user_id)
		@user = UserProfile.find(user_id)
		@subject = "Welcome to BedPost"
		mail(to: @user.email, subject: @subject)
	rescue Mongoid::Errors::DocumentNotFound
		Rails.logger.info "Tried to send a signup confirmation to a user who no longer exists: #{user_id}"
	end

	def removal(user_id, email, name, is_soft_delete)
		@user_id = user_id
		@email = email
		@name = name
		@is_soft_delete = is_soft_delete
		subject = "You successfully deleted your account with bedpost"
		mail(to: @email, subject: subject)
	end
end
