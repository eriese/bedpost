export default {
	install(Vue, options) {
		let prefix = options && options["prefix"] || "$"
		let i18nConfig = options.i18nConfig
		let methods = {}

		methods[`${prefix}_t`] = (scope, options) => i18nConfig.t(scope, options);

		Vue.mixin({methods});
	}
}
