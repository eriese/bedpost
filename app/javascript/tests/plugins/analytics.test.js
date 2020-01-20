import AnalyticsPlugin, {addTurbolinksTracking, sendAnalyticsEvent} from '@plugins/analytics';
import {mount, createLocalVue} from '@vue/test-utils';

describe('Analytics', () => {
	const origEventListener = document.addEventListener;
	const origDateNow = Date.now;
	afterEach(() => {
		window.gtag = undefined;
		window.onerror = null;
		document.addEventListener = origEventListener;
		Date.now = origDateNow;
	});

	function expectEventCall(actionName, options) {
		return expect(window.gtag).toHaveBeenCalledWith('event', actionName, options);
	}

	function mockEventListener() {
		const events = {};
		document.addEventListener = jest.fn((eventName, callBack) => events[eventName] = callBack);
		return events;
	}

	describe('addTurbolinksTracking', () => {
		it('adds listeners to 6 turbolinks events', () => {
			window.gtag = jest.fn();
			document.addEventListener = jest.fn();
			addTurbolinksTracking();
			expect(document.addEventListener).toHaveBeenCalledTimes(6);

			['visit', 'load', 'request-start', 'request-end', 'before-render', 'render'].forEach((funcName) => {
				expect(document.addEventListener).toHaveBeenCalledWith(`turbolinks:${funcName}`, expect.any(Function));
			});
		});

		it('adds a listener to the start event that resets the timing to Date.now()', () => {
			window.gtag = jest.fn();
			const events = mockEventListener();

			addTurbolinksTracking();
			Date.now = jest.fn();

			events['turbolinks:visit']();
			expect(Date.now).toHaveBeenCalledTimes(1);

			events['turbolinks:request-start']();
			expect(Date.now).toHaveBeenCalledTimes(2);

			events['turbolinks:before-render']();
			expect(Date.now).toHaveBeenCalledTimes(3);
		});

		it('adds a listener to the end event that sends a timing event with the time between the start and finish', () => {
			window.gtag = jest.fn();
			const events = mockEventListener();

			addTurbolinksTracking();

			Date.now = jest.fn();
			const returnValues = [1, 16];
			returnValues.forEach((v) => Date.now.mockReturnValueOnce(v));

			events['turbolinks:request-start']();
			events['turbolinks:request-end']();
			expectEventCall('timing_complete', expect.objectContaining({
				event_category: 'Tubolinks Timing',
				event_label: undefined,
				name: 'request-end',
				value: returnValues[1] - returnValues[0]
			}));
		});

		it('adds a listener to the visit event that sets window.timing', () => {
			window.gtag = jest.fn();
			const events = mockEventListener();
			addTurbolinksTracking();

			Date.now = jest.fn().mockReturnValueOnce('now');

			events['turbolinks:visit']();
			expect(window.timing).toEqual('now');
		});

		it('puts an onerror listener on the window to send an exception event', () => {
			window.gtag = jest.fn();
			addTurbolinksTracking();
			expect(window.onerror).toBeInstanceOf(Function);

			const errText = 'an error!';
			window.onerror(errText);
			expectEventCall('exception', {description: errText});
		});

		it('does nothing if gtag is undefined', () => {
			document.addEventListener = jest.fn();
			addTurbolinksTracking();
			expect(document.addEventListener).not.toHaveBeenCalled();
			expect(window.onerror).toBeNull();
		});
	});

	describe('sendAnalyticsEvent', () => {
		it('sends an event using gtag', () => {
			window.gtag = jest.fn();
			const actionName = 'name';
			const options = {opt1: 1};

			sendAnalyticsEvent(actionName, options);
			expect(window.gtag).toHaveBeenCalledWith('event', actionName, options);
		});
	});

	describe('Analytics Plugin', () => {
		const wrapperComponent = {
			template: '<div/>'
		};

		it('adds sendAnalyticsTimingEvent to the vue instance', () => {
			const localVue = createLocalVue();
			localVue.use(AnalyticsPlugin);

			const wrapper = mount(wrapperComponent, {localVue});
			expect(wrapper.vm.sendAnalyticsTimingEvent).toBeDefined();
		});

		it('adds sendAnalyticsEvent to the vue instance', () => {
			const localVue = createLocalVue();
			localVue.use(AnalyticsPlugin);

			const wrapper = mount(wrapperComponent, {localVue});
			expect(wrapper.vm.sendAnalyticsEvent).toBeDefined();
		});

		describe('sendAnalyticsTimingEvent', () => {
			it('sends an analytics event with the time since window.timing', () => {
				const localVue = createLocalVue();
				localVue.use(AnalyticsPlugin);
				const wrapper = mount(wrapperComponent, {localVue});

				window.gtag = jest.fn();
				window.timing = 1234;
				Date.now = jest.fn().mockReturnValueOnce(4567);
				wrapper.vm.sendAnalyticsTimingEvent();

				expect(window.gtag).toHaveBeenCalledWith('event', 'timing_complete', expect.objectContaining({
					value: 4567 - 1234
				}));
			});
		});
	});
});


