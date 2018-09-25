FactoryBot.define do
  factory :profile, aliases: [:with_internal, :profile1] do
    name { "Alice" }
    pronoun { "she" }
    anus_name { "asshole" }
    external_name { "clit" }
    internal_name { "pussy" }
  end

  factory :profile2, class: Profile, aliases: [:no_internal] do
  	name { "Bob" }
    pronoun { "he" }
    anus_name { "butt" }
    external_name { "dick" }
    internal_name { nil }
  end
end
