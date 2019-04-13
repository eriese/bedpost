FactoryBot.define do
  factory :encounter_contact do
    sequence(:position) {|n| n}
    subject {:user}
    object {:partner}
    barriers {Array.new}
  end
end
