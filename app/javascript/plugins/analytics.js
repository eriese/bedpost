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

	console.log(actionName, options);
	window.gtag('event', actionName, options);
};

/**
 * Get the number of milliseconds since the given startTime
 *
 * @param  {number} [startTime=window.timing] the time the event began
 * @return {number}           								the number of milliseconds since the startTime
 */
const timeSince = (startTime) => Date.now() - (startTime || window.timing);

/**
 * Send a timing event to google analytics
 *
 * @param  {string} name        the name of the event (not the event action name)
 * @param  {string} category    the event category
 * @param  {string} label       the timing event label
 * @param  {number} eventTiming the amount of time the event took if it is different from the time since window.timing
 */
const sendAnalyticsTimingEvent = function (name, category, label, eventTiming) {
	eventTiming = eventTiming !== undefined ? eventTiming : timeSince();

	sendAnalyticsEvent('timing_complete', {
		'name': name || 'load',
		'event_category': category,
		'event_label': label,
		'value': eventTiming,
	});
};

const turbolinksEventCategory = 'Tubolinks Timing';
const turbolinksPrefix = 'turbolinks:';

/**
 * Add turbolinks listeners to track the timing between a start event and its corresponding completion event
 * @param {string} startEvent the name of the start event without the prefix
 * @param {string} endEvent   the name of the end event without the prefix
 * @param {string} [eventName=endEvent]  the name of the analytics timing event to send
 */
function addTurbolinksListeners(startEvent, endEvent, eventName) {
	let eventTiming;
	document.addEventListener(`${turbolinksPrefix}${startEvent}`, () => eventTiming = Date.now());

	document.addEventListener(`${turbolinksPrefix}${endEvent}`, () => {
		sendAnalyticsTimingEvent(eventName || endEvent, turbolinksEventCategory, undefined, timeSince(eventTiming));
	});
}

/**
 * add timing tracking to turbolinks events
 */
export const addTurbolinksTracking = function() {

	// add an event listener to reset the timing clock whenever a new page visit begins
	document.addEventListener(`${turbolinksPrefix}visit`,
		() => window.timing = Date.now());

	// add an event listener to track the load timing
	document.addEventListener(`${turbolinksPrefix}load`,
		() => sendAnalyticsTimingEvent('load', turbolinksEventCategory));

	// add event listeners to track time between start and finish of request
	addTurbolinksListeners('request-start', 'request-end');
	// add event listeners to track time between start and finish of render
	addTurbolinksListeners('before-render', 'render');

	// add error reporting
	window.onerror = function(err) {
		sendAnalyticsEvent('exception', {
			description: err,
		});
	};
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
				sendAnalyticsEvent,
				sendAnalyticsTimingEvent,
			}
		});
	}
};
