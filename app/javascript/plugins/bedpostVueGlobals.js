import i18nConfig from '@modules/i18n-config';

export default {
	install(Vue, opts) {
		let prefix = opts && opts['prefix'] || '$';
		let methods = {};

		methods[`${prefix}_t`] = (scope, options) => i18nConfig.t(scope, options);
		methods[`${prefix}_l`] = (scope, value, options) => i18nConfig.l(scope, value, options);

		Vue.mixin({methods});
	}
};
