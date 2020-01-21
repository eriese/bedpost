import AnalyticsPlugin, {addTurbolinksTracking, sendAnalyticsEvent} from '@plugins/analytics';
import {mount, createLocalVue} from '@vue/test-utils';

describe('Analytics', () => {
	const origEventListener = document.addEventListener;
	afterEach(() => {
		window.gtag = undefined;
		window.onerror = null;
		document.addEventListener = origEventListener;
	});

	beforeEach(() => {
		performance.mark = jest.fn();
		performance.measure = jest.fn();
		window.clearTiming = jest.fn();
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

		it('adds a listener to the start event that adds a mark of the same name to performance', () => {
			window.gtag = jest.fn();
			const events = mockEventListener();

			addTurbolinksTracking();
			window.clearTiming.mockImplementationOnce(() => {
				performance.mark('pageload');
			});

			events['turbolinks:visit']();
			expect(performance.mark).toHaveBeenCalledTimes(1);

			events['turbolinks:request-start']();
			expect(performance.mark).toHaveBeenCalledTimes(2);

			events['turbolinks:before-render']();
			expect(performance.mark).toHaveBeenCalledTimes(3);
		});

		it('adds a listener to the end event that sends a timing event with the measure since the start mark', () => {
			window.gtag = jest.fn();
			const events = mockEventListener();

			addTurbolinksTracking();

			performance.measure.mockReturnValueOnce(15);

			events['turbolinks:request-start']();
			events['turbolinks:request-end']();
			expectEventCall('timing_complete', expect.objectContaining({
				event_category: 'Tubolinks Timing',
				event_label: undefined,
				name: 'request-end',
				value: 15
			}));
		});

		it('adds a listener to the visit event that calls window.clearTiming', () => {
			window.gtag = jest.fn();
			const events = mockEventListener();
			addTurbolinksTracking();

			window.clearTiming.mockClear();
			events['turbolinks:visit']();
			expect(window.clearTiming).toHaveBeenCalled();
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
				performance.measure.mockReturnValueOnce(4567);
				wrapper.vm.sendAnalyticsTimingEvent();

				expect(window.gtag).toHaveBeenCalledWith('event', 'timing_complete', expect.objectContaining({
					value: 4567
				}));
			});
		});
	});
});


