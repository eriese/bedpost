jest.mock('@plugins/analytics');
import {mount, createLocalVue} from '@vue/test-utils';
import {sendAnalyticsEvent, hasGTag} from '@plugins/analytics';
import TrackedForm from '@mixins/trackedForm';

const origWindowAddEvent = window.addEventListener;
const origDocumentAddEvent = document.addEventListener;
const origWindowRemoveEvent = window.removeEventListener;
const origDocumentRemoveEvent = document.removeEventListener;
hasGTag.mockReturnValue(true);

const wrapperComponent = {
	template: '<div/>',
	mixins: [TrackedForm],
	props: {
		$v: Object
	}
};

describe('Tracked form mixin', () => {
	afterEach(() => {
		window.addEventListener = origWindowAddEvent;
		window.removeEventListener = origWindowRemoveEvent;
		document.addEventListener = origDocumentAddEvent;
		document.removeEventListener = origDocumentRemoveEvent;
		window.gtag = undefined;
	});

	describe('addFormAbandomentTracking', () => {
		it('adds the same event listener or turbolinks:visit and window beforeunload', () => {
			window.addEventListener = jest.fn();
			document.addEventListener = jest.fn();
			mount(wrapperComponent);

			expect(window.addEventListener).toHaveBeenCalled();
			expect(document.addEventListener).toHaveBeenCalled();

			expect(window.addEventListener.mock.calls[0][1]).toEqual(document.addEventListener.mock.calls[0][1]);
		});

		it('does not add any listeners if analytics is turned off', () => {
			hasGTag.mockReturnValueOnce(false);
			window.addEventListener = jest.fn();
			document.addEventListener = jest.fn();
			mount(wrapperComponent);

			expect(window.addEventListener).not.toHaveBeenCalled();
			expect(document.addEventListener).not.toHaveBeenCalled();
		});

		it('does not add any listeners if analytics is the form is marked to ignore abandons', () => {
			window.addEventListener = jest.fn();
			document.addEventListener = jest.fn();
			mount(wrapperComponent, {attrs: {
				'ignore-abandons': true
			}});

			expect(window.addEventListener).not.toHaveBeenCalled();
			expect(document.addEventListener).not.toHaveBeenCalled();
		});

		describe('on form abandonment', () => {
			it('does not send an event if the form has submitted successfully', () => {
				let listener;
				window.addEventListener = jest.fn((e, cb) => listener = cb);

				const wrapper = mount(wrapperComponent);
				wrapper.vm.trackSuccess();
				sendAnalyticsEvent.mockClear();

				listener();
				expect(sendAnalyticsEvent).not.toHaveBeenCalled();
			});

			it('removes both event listeners', () => {
				window.removeEventListener = jest.fn();
				document.removeEventListener = jest.fn();

				let listener;
				window.addEventListener = jest.fn((e, cb) => listener = cb);

				const wrapper = mount(wrapperComponent);
				wrapper.vm.trackSuccess();
				listener();

				expect(window.removeEventListener).toHaveBeenCalledWith('beforeunload', listener);
				expect(document.removeEventListener).toHaveBeenCalledWith('turbolinks:visit', listener);
			});

			it('sends "Fields touched: none" as the event label if no fields were touched', () => {
				let listener;
				window.addEventListener = jest.fn((e, cb) => listener = cb);
				window.gtag = jest.fn();

				mount(wrapperComponent, {
					propsData: {
						$v: {
							$anyDirty: false,
							$dirty: false,
							formData: {
								$anyDirty: false,
								params: {
									p: null
								},
								p: {
									$anyDirty: false,
									$dirty: false
								}
							}
						},
						name: 'name'
					}
				});

				sendAnalyticsEvent.mockClear();
				listener();

				expect(sendAnalyticsEvent).toHaveBeenCalledWith('name', {
					'event_category': 'form_abandonment',
					'event_label': 'Fields touched: none'
				});
			});

			it('recursively looks for dirty fields if any are dirty', () => {
				let listener;
				window.addEventListener = jest.fn((e, cb) => listener = cb);
				window.gtag = jest.fn();

				mount(wrapperComponent, {
					propsData: {
						$v: {
							$anyDirty: true,
							formData: {
								$params: {
									field1: null,
									field2: null,
									field3: null
								},
								field1: {
									$anyDirty: true,
									$dirty: true
								},
								field2: {
									$anyDirty: true,
									$dirty: false,
									$params: {
										sub1: null,
										blank: {}
									},
									sub1: {
										$anyDirty: true,
										$dirty: true
									}
								},
								field3: {
									$anyDirty: false
								}
							}
						},
						name: 'name'
					}
				});

				sendAnalyticsEvent.mockClear();
				listener();

				expect(sendAnalyticsEvent).toHaveBeenCalledWith('name', {
					'event_category': 'form_abandonment',
					'event_label': 'Fields touched: field1,field2: (sub1)'
				});
			});
		});
	});

	describe('trackError', () => {
		it('does nothing by default', () => {
			const wrapper = mount(wrapperComponent);
			sendAnalyticsEvent.mockClear();
			wrapper.vm. trackError('an error');
			expect(sendAnalyticsEvent).not.toHaveBeenCalled();
		});

		it('sends the error text as a form failure event if the form is marked track-failures', () => {
			const wrapper = mount(wrapperComponent, {
				propsData: {
					name: 'name'
				},
				attrs: {
					'track-failures': true
				}
			});

			sendAnalyticsEvent.mockClear();
			wrapper.vm.trackError('an error');
			expect(sendAnalyticsEvent).toHaveBeenCalledWith('name', {
				'event_category': 'form_failure',
				'event_label': 'an error'
			});
		});
	});

	describe('trackSuccess', () => {
		it('sets submitted to true', () => {
			const wrapper = mount(wrapperComponent);
			expect(wrapper.vm.submitted).toBe(false);
			wrapper.vm.trackSuccess();
			expect(wrapper.vm.submitted).toBe(true);
		});

		it('sends a given analytics event', () => {
			const event = ['event_name', {option1: 'yes'}];
			const wrapper = mount(wrapperComponent, {
				propsData: {
					analyticsEvent: event
				}
			});

			sendAnalyticsEvent.mockClear();
			wrapper.vm.trackSuccess();

			expect(sendAnalyticsEvent).toHaveBeenCalledWith(...event);
		});
	});
});
