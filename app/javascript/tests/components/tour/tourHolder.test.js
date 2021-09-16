import {createLocalVue, mount} from "@vue/test-utils"
import TourHolder from "@components/tour/TourHolder.vue"
import VTour from "vue-tour/src/components/VTour.vue"

describe("TourHolder component", () => {
	let localVue
	beforeEach(() => {
		localVue = createLocalVue()
		localVue.prototype.$tours = {};
		localVue.prototype.$_t = jest.fn();
	})
	describe("when there is no tour", () => {
		test("it mounts an empty div", () => {
			const wrapper = mount(TourHolder, {
				stubs: {
					'v-step': true
				},
				localVue
			});

			expect(wrapper.element.tagName).toEqual('DIV');
			expect(wrapper.classes('tourguide-empty')).toBeTruthy();
			expect(wrapper.vm.tour).toBeFalsy()
		})
	})

	describe("when a tour is loaded", () => {
		test("it changes to a v-tour component", done => {
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
				expect(wrapper.findComponent(VTour)).not.toBeUndefined();
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

			test('it immediately emits tour-started', (done) => {

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null
					},
					stubs: {
						'v-step': true
					},
					localVue
				});

				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text'}]
				});

				wrapper.vm.$nextTick().then(() => {
					expect(wrapper.emitted('tour-started')).toHaveLength(1);
					done();
				});
			});

			test('it runs the tour immediately if the tour has run before on this page load', (done) => {
				// const startMock = jest.fn();

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null,
						tourRuns: 1,
					},
					stubs: {
						'v-step': true
					},
					localVue
				});

				const spy = jest.spyOn(wrapper.vm, 'startTour');

				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text'}]
				});

				wrapper.vm.$nextTick().then(() => {
					jest.advanceTimersByTime(0);
					expect(spy).toHaveBeenCalledTimes(1);
					done();
				});
			});

			test('it runs the tour after a delay if it is the first run on page load', (done) => {
				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null
					},
					stubs: {
						'v-step': true
					},
					localVue
				});

				const startMock = jest.spyOn(wrapper.vm, 'startTour');
				wrapper.setProps({
					steps: [{target: '#t-1', content: 'some text'}]
				});

				wrapper.vm.$nextTick().then(() => {
					expect(startMock).not.toHaveBeenCalled();
					jest.advanceTimersByTime(2000);
					expect(startMock).toHaveBeenCalledTimes(1);
					done();
				});
			});

			test('it sets up an IntersectionObserver if the first step requires waiting for the target to be in view', (done) => {

				const wrapper = mount(TourHolder, {
					propsData: {
						steps: null,
						tourRuns: 1
					},
					stubs: {
						'v-step': true
					},
					localVue
				});

				const startMock = jest.spyOn(wrapper.vm, 'startTour').mockImplementation(jest.fn());

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

				wrapper.vm.$nextTick().then(() => {
					jest.advanceTimersByTime(0);
					expect(intersectionCallback).not.toBeUndefined();
					expect(startMock).not.toHaveBeenCalled();

					intersectionCallback([]);
					expect(startMock).toHaveBeenCalledTimes(1);
					done();
				});
			});
		});
	});

	describe("when a tour is stopped", () => {
		test("it emits a tour-stopped event", done => {

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
				done();
			})
		})
	})
})
