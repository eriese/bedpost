module I18n
	module Backend
		module Pluralization
			def pluralize(locale, entry, count)
				return entry unless entry.is_a?(Hash) and count

				pluralizer = pluralizer(locale)
				rule = pluralizer[:rule]
				if rule.respond_to?(:call)
					key = count == 0 && entry.has_key?(:zero) ? :zero : rule.call(count)
					unless entry.has_key?(key)
						raise InvalidPluralizationData.new(entry, count,
																																									key) if pluralizer.has_key?(:required_keys) && pluralizer[:required_keys].include?(key)

						key = pluralizer[:default_key]
					end
					entry[key]
				else
					super
				end
			end

			protected

			def pluralizer(locale)
				pluralizers[locale] ||= I18n.t(:'i18n.plural', :locale => locale, :resolve => false)
			end
		end
	end
end
