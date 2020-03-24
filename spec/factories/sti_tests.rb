FactoryBot.define do
	factory :sti_test do
		transient do
			tested_for { [] }
		end
		tested_on { Date.current }

		after(:build) do |tst, evaluator|
			next if evaluator.tested_for.empty?

			evaluator.tested_for.each do |t|
				t_is_array = t.is_a? Array
				diagnosis = t_is_array ? t[0] : t
				positive = t_is_array ? t[1] : false
				build(:sti_test_result, tested_for_id: diagnosis, positive: positive, sti_test: tst)
			end
		end
	end
end
