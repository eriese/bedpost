FactoryBot.define do
  factory :diagnosis do
    name { :hpv }
    _id {name}
    gestation_min { 1 }
    gestation_max { 3 }
    in_fluids { true }
    category { [:treatable] }
  end
end
