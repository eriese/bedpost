FactoryBot.define do
	factory :partnership do
		nickname { 'nickname' }
		familiarity { 5 }
		exclusivity { 5 }
		communication { 5 }
		trait :with_partner do
			association :partner, factory: :user
		end
	end
end
