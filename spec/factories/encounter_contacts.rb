FactoryBot.define do
  factory :encounter_contact do
    contact_type {:touched}
    sequence(:position) {|n| n}
    subject {:user}
    object {:partner}
    barriers {Array.new}
  end
end
