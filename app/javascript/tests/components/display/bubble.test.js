import {mount} from "@vue/test-utils"
import Bubble from "@components/display/Bubble.vue"

describe("Bubble component", () => {
	test("It renders the slot content", () => {
		const txt = "some text"
		const wrapper = mount(Bubble, {
			slots: {
				default: txt
			}
		})

		expect(wrapper.text()).toBe(txt)
	})
})
