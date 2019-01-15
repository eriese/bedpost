FactoryBot.define do
  factory :partnership do
    familiarity { 0 }
    exclusivity { 0 }
    communication { 0 }

    trait :with_partner do
    	association :partner, factory: :user
    end
  end
end
