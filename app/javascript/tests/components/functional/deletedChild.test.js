import {mount} from "@vue/test-utils"
import DeletedChild from '@components/functional/DeletedChild';

describe('DeletedChild functional component', () => {
	describe('with a new record', () => {
		let wrapper = mount(DeletedChild, {
			propsData: {
				item: {
					newRecord: true
				}
			}
		});

		test('it is empty', () => {
			expect(wrapper.element.tagName).toBeUndefined();
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
			expect(wrapper.element).not.toBeEmptyDOMElement();
		})

		test('it has a hidden input named _destroy with a value of true', () => {
			expect(wrapper.find('input[type=hidden][name="nm[_destroy]"][value=true]')).toBeTruthy();
		})

		test('it has a hidden input with the idKey in the name and that field from the item as the value', () => {
			expect(wrapper.find('input[type=hidden][name="nm[val]"][value=someValue]')).toBeTruthy();
		})
	})
})
