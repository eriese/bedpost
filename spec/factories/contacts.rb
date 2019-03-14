FactoryBot.define do
  factory :contact do
    barriers {true}
    sequence(:order) {|n| n}
    contact_type {:touched}
  end
end
