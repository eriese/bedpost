import {mount} from "@vue/test-utils";
import tourRoot from "@mixins/tourRoot.js";
import TourHolder from "@components/tour/TourHolder.vue";

import axios from 'axios';
jest.mock('axios')

const getFalse = () => Promise.resolve({
	data: {has_tour: false}
})

const getTrue = () => Promise.resolve({
	data: {has_tour: true}
})

const tourData = {page_name: "page", tour_nodes: []}
const getTour = () => Promise.resolve({
	data: tourData
})

const mountBase = (mock, options) => {
	axios.get.mockClear();
	if (mock) {
		axios.get.mockImplementationOnce(mock);
	}

	return mount({
		template: "<div/>",
		mixins: [tourRoot],
		methods: {
			gtagSet: jest.fn(),
			sendAnalyticsEvent: jest.fn()
		}
	}, options)
}

const getPromise = () => Promise.resolve()

axios.get.mockImplementation(getFalse);
axios.put.mockImplementation(getPromise)

describe("Tour Root mixin", () => {
	test("it adds {tourSteps: null, hasTour: false, and tourData: null} to data", () => {
		const wrapper = mountBase()

		expect(wrapper.vm.tourSteps).toBe(null);
		expect(wrapper.vm.hasTour).toBe(false);
		expect(wrapper.vm.tourData).toBe(null);
	})

	describe("methods", () => {
		describe("setTourSteps", () => {
			test("it sets the tourSteps data property", () => {
				const wrapper = mountBase()

				const steps = []
				wrapper.setData({tourData: {tour_nodes: steps}})
				wrapper.vm.setTourSteps()
				expect(wrapper.vm.tourSteps).toBe(steps)
			})
		})

		describe("onTourStop", () => {
			test("it sets the tourSteps back to null", () => {
				const wrapper = mountBase()

				const steps = [1, 2]
				wrapper.setData({tourSteps: steps});
				wrapper.vm.onTourStop();
				expect(wrapper.vm.tourSteps).toBe(null);
			})

			test("it posts the tour completion", () => {
				const wrapper = mountBase();
				axios.put.mockClear()

				wrapper.vm.onTourStop()
				expect(axios.put).toHaveBeenCalledTimes(1);
			})
		})

		describe("loadTour", () => {
			test("it is called on create", () => {
				const loadTour = jest.fn()
				const wrapper = mount({
					template: "<div/>",
					mixins: [tourRoot]
				}, {
					methods: {
						loadTour
					}
				})

				expect(loadTour).toHaveBeenCalledTimes(1);
			})

			describe("when there is a tour for the page that the user has not seen", () => {
				test("it sets the tour steps after loading", async () => {
					const wrapper = mountBase(getTour);
					await wrapper.vm.$nextTick(() => {
						expect(wrapper.vm.tourSteps).toEqual(tourData.tour_nodes)
					})
				})
			})

			describe("when a tour has already been loaded", () => {
				test("it does not make an axios call", async () => {
					const wrapper = mountBase(getTour)
					axios.get.mockClear();
					await wrapper.vm.$nextTick(() => {
						wrapper.vm.loadTour();

						expect(axios.get).not.toHaveBeenCalled()
					})
				})

				test("it does set the tourSteps", async() => {
					const wrapper = mountBase(getTour)
					wrapper.setData({tourSteps: null})
					wrapper.vm.loadTour()
					await wrapper.vm.$nextTick(() => {
						expect(wrapper.vm.tourSteps).toEqual(tourData.tour_nodes)
					})
				} )
			})

			describe("when a tour exists but the user has seen it", () => {
				test("it sets hasTour to true but does not set the tourSteps", async() => {
					const setTourSteps = jest.fn()
					const wrapper = mountBase(getTrue, {
						methods: {setTourSteps}
					});

					await wrapper.vm.$nextTick(() => {
						expect(wrapper.vm.hasTour).toBe(true)
						expect(setTourSteps).not.toHaveBeenCalled()
					})
				})
			})
		})
	})

	describe("components", () => {
		test("it adds the TourHolder component", () => {
			const wrapper = mount({
				template: "<div><tour-holder/></div>",
				mixins: [tourRoot]
			})

			expect(wrapper.contains(TourHolder)).toBe(true);
		})
	})
})
