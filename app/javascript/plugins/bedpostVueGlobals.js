import i18nConfig from "@modules/i18n-config";

const mx = {
	install(Vue, options) {
		let prefix = options && options["prefix"] || "$"
		let methods = {}

		methods[`${prefix}_t`] = (scope, options) => i18nConfig.t(scope, options);

		Vue.mixin({methods});
		// console.log(methods);
	}
}

export default async function(givenVue) {
	await i18nConfig.setup();

	givenVue.use(mx);
	// console.log(new givenVue());
}
