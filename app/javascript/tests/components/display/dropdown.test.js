import {shallowMount} from '@vue/test-utils';
import DropDown from '@components/display/DropDown.vue';
// import {gsap} from 'gsap';

describe('Dropdown component', () => {
	beforeEach(() => {
		jest.useFakeTimers();
	});

	afterEach(() => {
		jest.runAllTimers();
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
});
