require "i18n/backend/pluralization"

I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)

FIRST_ELEVEN = {
	0 => :zero,
	1 => :one,
	2 => :two,
	3 => :three,
	4 => :four,
	5 => :five,
	6 => :six,
	7 => :seven,
	8 => :eight,
	9 => :nine,
	10 => :ten
}

I18n.backend.store_translations :en, i18n: {
	plural: {
		default_key: :other,
		required_keys: [:zero, :other],
		rule: lambda { |n|
			FIRST_ELEVEN.has_key?(n) ? FIRST_ELEVEN[n] : :other
		}
	}
}
