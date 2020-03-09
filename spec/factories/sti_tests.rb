FactoryBot.define do
	factory :sti_test do
		tested_on { DateTime.current.beginning_of_day }
		tested_for { :hpv }
	end
end
