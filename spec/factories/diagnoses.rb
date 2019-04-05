FactoryBot.define do
  factory :diagnosis do
    name { "" }
    gestation_min { 1 }
    gestation_max { 1 }
    barriers_effective { false }
    category { "" }
  end
end
