class RemoveOrphanedProfileJob < ApplicationJob
	queue_as :default

	def perform(profile_id)
		return if profile_id.blank?

		profile = Profile.find(profile_id)
		return unless profile._type == 'Profile'

		num_partnered_to = UserProfile.where_partnered_to(profile.id).count
		profile.destroy if num_partnered_to == 0
	rescue Mongoid::Errors::DocumentNotFound
		Rails.logger.warn('tried to destroy a user who had already been destroyed')
	end
end
