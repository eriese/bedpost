import {mount} from "@vue/test-utils"
import DeletedChild from '@components/functional/DeletedChild';

describe('with a new record', () => {
	let wrapper = mount(DeletedChild, {
		propsData: {
			item: {
				newRecord: true
			}
		}
	});

	test('it is empty', () => {
		expect(wrapper.isEmpty()).toBe(true);
	});
})

describe('with an old record', () => {
	let wrapper = mount(DeletedChild, {
		propsData: {
			baseName: "nm",
			idKey: "val",
			item: {
				newRecord: false,
				val: "someValue"
			}
		}
	});

	test('it is not empty', () => {
		expect(wrapper.isEmpty()).toBe(false);
	})

	test('it has a hidden input named _destroy with a value of true', () => {
		expect(wrapper.contains('input[type=hidden][name="nm[_destroy]"][value=true]')).toBe(true);
	})

	test('it has a hidden input with the idKey in the name and that field from the item as the value', () => {
		expect(wrapper.contains('input[type=hidden][name="nm[val]"][value=someValue]')).toBe(true);
	})
})
