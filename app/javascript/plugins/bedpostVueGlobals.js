import i18nConfig from "@modules/i18n-config";

export default {
	install(Vue, options) {
		let prefix = options && options["prefix"] || "$"
		let methods = {}

		methods[`${prefix}_t`] = (scope, options) => i18nConfig.t(scope, options);

		Vue.mixin({methods});
	}
}
