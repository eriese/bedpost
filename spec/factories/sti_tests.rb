FactoryBot.define do
	factory :sti_test do
		tested_on { DateTime.current.beginning_of_day }
		tested_for_id { :hpv }
		positive { false }
	end
end
