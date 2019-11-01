import {mount} from "@vue/test-utils";
import tourRoot from "@mixins/tourRoot.js";
import TourHolder from "@components/tour/TourHolder.vue";
import TourButton from "@components/tour/TourButton.vue";

describe("Tour Root mixin", () => {
	test("it adds null tourSteps data property", () => {
		const wrapper = mount({
			template: "<div/>",
			mixins: [tourRoot]
		})

		expect(wrapper.vm.tourSteps).toBe(null);
	})

	describe("setTourSteps method", () => {
		test("it sets the tourSteps data property", () => {
			const wrapper = mount({
				template: "<div/>",
				mixins: [tourRoot]
			})

			const steps = [1, 2]
			wrapper.vm.setTourSteps(steps)
			expect(wrapper.vm.tourSteps).toBe(steps)
		})
	})

	describe("onTourStop method", () => {
		test("it sets the tourSteps back to null", () => {
			const wrapper = mount({
				template: "<div/>",
				mixins: [tourRoot]
			})

			const steps = [1, 2]
			wrapper.vm.setTourSteps(steps);
			wrapper.vm.onTourStop();
			expect(wrapper.vm.tourSteps).toBe(null);
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

		test("it adds the TourButton component", () => {
			TourButton.created = jest.fn()

			const wrapper = mount({
				template: "<div><tour-button/></div>",
				mixins: [tourRoot],
			})

			expect(wrapper.contains(TourButton)).toBe(true);
		})
	})
})
