module UserProfileHelpers
	private
	@@dummy = nil

	public
	def dummy_user
		@@dummy ||= FactoryBot.create(:user_profile)

		return @@dummy
	end

	def dummy_user_session
		{user_id: dummy_user.id}
	end

	def clear_dummy
		@@dummy.destroy if @@dummy
		@@dummy = nil
	end
end
