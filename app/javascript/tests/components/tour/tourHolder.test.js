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

		test("it runs the tour", done => {
			const localVue = createLocalVue()
			localVue.prototype.$tours = {}

			const startMock = jest.fn()

			const wrapper = mount(TourHolder, {
				propsData: {
					steps: null
				},
				methods: {
					startTour: startMock
				},
				localVue
			})

			wrapper.setProps({steps: [{target: "#t-1", content: "some text"}]})

			setTimeout(() => {
				expect(startMock).toHaveBeenCalledTimes(1);
				done()
			})
		})
	})

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
