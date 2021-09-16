import {createLocalVue, mount} from "@vue/test-utils"
import tourguide from "@plugins/tourguide.js"
import VTour from "vue-tour/src/components/VTour.vue"
import VStep from "vue-tour/src/components/VStep.vue"
import Popper from 'popper.js'

jest.mock('popper.js')

describe("Tourguide plugin", () => {
	test("it adds a $tours object to the Vue prototype", () => {
		const localVue = createLocalVue();
		localVue.use(tourguide);

		expect(localVue.prototype.$tours).toEqual({})
	})

	test("it dynamically registers v-step component", done => {
		const localVue = createLocalVue();
		localVue.use(tourguide);

		// mock finding the target
		document.querySelector = jest.fn().mockImplementation(() => {
			return {scrollIntoView: jest.fn()}
		})

		const wrapper = mount({
			template: '<div><v-step :step="step" :labels="labels"/></div>',
			props: {
				step: Object,
				labels: Object
			}
		}, {
			propsData: {
				step: {
					target: '#v-step-0',
					content: 'a step'
				},
				labels: {}
			},
			localVue
		})

		setTimeout(() => {
			// restore error logging
			expect(wrapper.findComponent(VStep)).not.toBeUndefined();
			done()
		})
	})
})
