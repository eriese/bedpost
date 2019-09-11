import I18n from 'i18n-js';

let mod = I18n;
let {locale, defaultLocale, translations} = window.I18nConfig;
mod.locale = locale;
mod.defaultLocale = defaultLocale;
mod.translations = translations

// add a pluralization rule that checks english pluralization for any number up to 10 and defaults to other
mod.pluralization["en"] = function(count) {
	switch(parseInt(count)) {
		case 0: return ["zero", "other"];
		case 1: return ["one", "other"];
		case 2: return ["two", "other"];
		case 3: return ["three", "other"];
		case 4: return ["four", "other"];
		case 5: return ["five", "other"];
		case 6: return ["six", "other"];
		case 7: return ["seven", "other"];
		case 8: return ["eight", "other"];
		case 9: return ["nine", "other"];
		case 10: return ["ten", "other"];
		default: return ["other"]
	}
}

export default mod;
