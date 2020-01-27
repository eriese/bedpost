FactoryBot.define do
	factory :user_profile, parent: :profile, class: UserProfile, aliases: [:user_with_internal, :user1] do
		sequence(:email) { |n| "#{name}#{n}@example.com".downcase }
		password { 'passw0rd' }
		password_confirmation { 'passw0rd' }
		first_time {false}
		terms { {tou: DateTime.now + 1.day, privacy: DateTime.now + 1.day} }

		factory :user_profile_new do
			first_time { true }
			terms { Hash.new }
		end
	end
end
