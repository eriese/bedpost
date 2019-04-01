FactoryBot.define do
  factory :contact do
    contact_type {:touched}
    sequence(:position) {|n| n}
  end
end
