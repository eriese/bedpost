FactoryBot.define do
  factory :profile, aliases: [:with_internal, :profile1] do
    name { "Alice" }
    anus_name { "asshole" }
    external_name { "clit" }
    internal_name { "pussy" }
    association :pronoun, strategy: :build_stubbed
  end

  factory :profile2, class: Profile, aliases: [:no_internal] do
  	name { "Bob" }
    anus_name { "butt" }
    external_name { "dick" }
    internal_name { nil }
    association :pronoun, strategy: :build_stubbed
  end
end
