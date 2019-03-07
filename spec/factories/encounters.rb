FactoryBot.define do
  factory :encounter do
    notes {"blah blah"}
    fluids {false}
    self_risk {3}
    took_place {nil}
  end
end
