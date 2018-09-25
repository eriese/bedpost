FactoryBot.define do
  factory :user_profile, parent: :profile, class: UserProfile, aliases: [:user_with_internal, :user1] do
    sequence(:email) { |n| "#{name}#{n}@example.com".downcase }
    uid {"12345"}
    password {"passw0rd"}
  end
end
