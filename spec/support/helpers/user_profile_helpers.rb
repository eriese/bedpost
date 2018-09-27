module UserProfileHelpers
	private
	@@dummy = nil

	public
	def dummy_user
		@@dummy ||= FactoryBot.create(:user_profile)

		return @@dummy
	end

	def clear_dummy
		@@dummy.destroy if @@dummy
	end
end
