import {shallowMount} from '@vue/test-utils';
import DropDown from '@components/display/DropDown.vue';

describe('Dropdown component', () => {
	beforeEach(() => {
		jest.useFakeTimers();
		jest.clearAllTimers();
	});

	afterEach(() => {
		jest.clearAllTimers();
		jest.useRealTimers();
	});

	it('adds a closed class when toggling from open, but before it is actually closed', () => {
		const wrapper = shallowMount(DropDown, {
			propsData: {
				startOpen: true
			},
			stubs: {
				'arrow-button': true
			}
		});

		wrapper.vm.toggle();
		expect(wrapper.classes()).toContain('dropdown--is-closed');
		expect(wrapper.vm.isOpen).toBe(true);
	});

	it('marks itself as no longer closing once it is closed', () => {
		const wrapper = shallowMount(DropDown, {
			propsData: {
				startOpen: true
			},
			stubs: {
				'arrow-button': true
			}
		});

		wrapper.vm.toggle();
		expect(wrapper.vm.closing).toBe(true);
		expect(wrapper.vm.isOpen).toBe(true);

		jest.runAllTimers();
		expect(wrapper.vm.closing).toBe(false);
		expect(wrapper.vm.isOpen).toBe(false);
	});
});
