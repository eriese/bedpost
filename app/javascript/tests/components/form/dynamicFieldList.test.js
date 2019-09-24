import {shallowMount} from "@vue/test-utils";
import DynamicFieldList from "@components/form/DynamicFieldList.vue";

describe("Dynamic Field List Component", () => {
	global.gon = {
		dummy: {}
	}

	Array.prototype.findLastIndex = jest.fn()

	test('It mounts with an empty list', async() => {
		let list = [];
		let dfl = shallowMount(DynamicFieldList, {
			methods: {
				setFocus: (index, focusFirst) => {}
			},
			propsData: {
				componentType: "encounter-contact-field",
				list: [],
				baseName: "encounter[contacts_attributes]"
			},
			stubs: {
				'encounter-contact-field': true
			}
		})

		expect(dfl.exists()).toBeTruthy();
	})
})
