/**
 * Is google analytics enabled on the page?
 *
 * @return {boolean} whether the gtag function exists on the window
 */
export const hasGTag = () => typeof window.gtag == 'function';

/**
 * Send an event to google analytics
 *
 * @param  {string} actionName the name of the event action
 * @param  {object} options    event options
 */
export const sendAnalyticsEvent = function (actionName, options) {
	// if there's no analytics, do nothing
	if (!hasGTag()) {return;}

	window.gtag('event', actionName, options);
};

/**
 * @module
 *
 * A module for interactions with google analytics
 */
export default {
	install(Vue) {
		Vue.mixin({
			methods: {
				sendAnalyticsEvent
			}
		});
	}
};
