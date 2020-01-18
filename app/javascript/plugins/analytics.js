export const hasGTag = () => typeof window.gtag != 'function';
export const sendAnalyticsEvent = function (actionName, options) {
	if (!hasGTag()) {return;}

	window.gtag('event', actionName, options);
};

export default {
	install(Vue) {
		Vue.mixin({
			methods: {
				sendAnalyticsEvent
			}
		});
	}
};
