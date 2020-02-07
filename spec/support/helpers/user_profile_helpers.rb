module UserProfileHelpers
	private
	@@_dummy_user = nil
	@@_dummy_pronoun = nil

	public
	def dummy_user
		dummy_pronoun
		@@_dummy_user ||= FactoryBot.create(:user_profile, name: 'dummy')
	end

	def dummy_pronoun
		@@_dummy_pronoun ||= FactoryBot.create(:pronoun, subject: 'dummy')
		return @@_dummy_pronoun
	end

	def dummy_user_session
		sign_in dummy_user
		nil
	end

	def clear_dummy_user
		@@_dummy_user.destroy if @@_dummy_user
		@@_dummy_user = nil
	end

	def clear_all_dummies
		clear_dummy_user
		@@_dummy_pronoun.destroy if @@_dummy_pronoun
		@@_dummy_pronoun = nil
	end
end
