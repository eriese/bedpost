FactoryBot.define do
  factory :encounter_contact do
    contact_type {:touched}
    sequence(:position) {|n| n}
  end
end
