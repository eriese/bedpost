FactoryBot.define do
  factory :user_profile, parent: :profile, class: UserProfile, aliases: [:user_with_internal, :user1] do
    sequence(:email) { |n| "#{name}#{n}@example.com".downcase }
    password {"passw0rd"}
    password_confirmation {"passw0rd"}
  end
end
