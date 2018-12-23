FactoryBot.define do
  factory :profile, aliases: [:with_internal, :profile1] do
    name { "Alice" }
    anus_name { "asshole" }
    external_name { "clit" }
    internal_name { "pussy" }
    pronoun {UserProfileHelpers.dummy_pronoun}
  end

  factory :profile2, class: Profile, aliases: [:no_internal] do
  	name { "Bob" }
    anus_name { "butt" }
    external_name { "dick" }
    internal_name { nil }
    pronoun {UserProfileHelpers.dummy_pronoun}
  end
end
