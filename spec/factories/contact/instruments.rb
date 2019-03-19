FactoryBot.define do
  factory :contact_instrument, class: 'Contact::Instrument' do
    _id {name}
  end
end
