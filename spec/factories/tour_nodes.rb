FactoryBot.define do
  factory :tour_node do
    target { '#selector' }
    sequence(:position) { |n| n }
    content { "body goes here" }
  end
end
