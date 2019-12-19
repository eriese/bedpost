import {createLocalVue, mount} from "@vue/test-utils"
import TourHolder from "@components/tour/TourHolder.vue"
import VTour from "vue-tour/src/components/VTour.vue"

describe("TourHolder component", () => {
	describe("when there is no tour", () => {
		test("it mounts an empty div", () => {
			const wrapper = mount(TourHolder)

			expect(wrapper.is("div.tourguide-empty")).toBe(true);
			expect(wrapper.vm.tour).toBeFalsy()
		})
	})

	describe("when a tour is loaded", () => {
		test("it changes to a v-tour component", done => {
			const localVue = createLocalVue()
			localVue.prototype.$tours = {}

			const wrapper = mount(TourHolder, {
				propsData: {
					steps: null
				},
				stubs: {
					'v-step': true
				},
				localVue
			})

			wrapper.setProps({steps: [{target: "#t-1", content: "some text"}]})

			setTimeout(() => {
				expect(wrapper.contains(VTour)).toBe(true);
				done()
			})
		})

		describe('running the tour', () => {
			beforeAll(() => {
				jest.useFakeTimers();
			});

			afterAll(() => {
				jest.useRealTimers();
			});

			test('it immediately emits tour-started', () => {
				const localVue = createLocalVue();
				localVue.prototype.$tours = {};

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null
					},
					methods: {
						startTour: jest.fn(),
					},
					localVue
				});

				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text'}]
				});

				expect(wrapper.emitted('tour-started')).toHaveLength(1);
			});

			test('it runs the tour immediately if the tour has run before on this page load', () => {
				const localVue = createLocalVue();
				localVue.prototype.$tours = {};
				const startMock = jest.fn();

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null,
						tourRuns: 1,
					},
					methods: {
						startTour: startMock,
					},
					localVue
				});

				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text'}]
				});

				jest.advanceTimersByTime(0);
				expect(startMock).toHaveBeenCalledTimes(1);
			});

			test('it runs the tour after a delay if it is the first run on page load', () => {
				const localVue = createLocalVue();
				localVue.prototype.$tours = {};

				const startMock = jest.fn();

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null
					},
					methods: {
						startTour: startMock
					},
					localVue
				});

				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text'}]
				});

				expect(startMock).not.toHaveBeenCalled();
				jest.advanceTimersByTime(2000);
				expect(startMock).toHaveBeenCalledTimes(1);
			});

			test('it sets up an IntersectionObserver if the first step requires waiting for the target to be in view', () => {
				const localVue = createLocalVue();
				localVue.prototype.$tours = {};

				const startMock = jest.fn();

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null,
						tourRuns: 1
					},
					methods: {
						startTour: startMock
					},
					localVue
				});

				let intersectionCallback;
				global.IntersectionObserver = class IntersectionObserver {
					constructor(callback) {
						intersectionCallback = callback;
					}
					observe() {}
				};

				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text', await_in_view: true}]
				});

				jest.advanceTimersByTime(0);
				expect(intersectionCallback).not.toBeUndefined();
				expect(startMock).not.toHaveBeenCalled();

				intersectionCallback([]);
				expect(startMock).toHaveBeenCalledTimes(1);
			});
		});
	});

	describe("when a tour is stopped", () => {
		test("it emits a tour-stopped event", done => {
			const localVue = createLocalVue()
			localVue.prototype.$tours = {}

			const wrapper = mount(TourHolder, {
				propsData: {
					steps: null
				},
				stubs: {
					'v-step': true
				},
				localVue
			})

			wrapper.setProps({steps: [{target: "#t-1", content: "some text"}]})
			setTimeout(() => {
				wrapper.vm.tour.stop();
				expect(wrapper.emitted()['tour-stopped']).toBeTruthy()
				done()
			})
		})
	})
})
