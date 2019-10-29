FactoryBot.define do
  factory :tour_node do
    target { '#selector' }
    sequence(:position) { |n| n }
    body { "body goes here" }
  end
end
