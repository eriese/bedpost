FactoryBot.define do
  factory :profile, aliases: [:with_internal, :profile1] do
    name { "Alice" }
    anus_name { "asshole" }
    external_name { "clit" }
    internal_name { "pussy" }
    pronoun_id {UserProfileHelpers.dummy_pronoun.id}
    can_penetrate {false}
  end

  factory :profile2, class: Profile, aliases: [:no_internal] do
  	name { "Bob" }
    anus_name { "butt" }
    external_name { "dick" }
    can_penetrate {true}
    internal_name { nil }
    pronoun_id {UserProfileHelpers.dummy_pronoun.id}
  end
end
