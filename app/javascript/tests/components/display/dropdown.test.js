import {shallowMount} from '@vue/test-utils';
import DropDown from '@components/display/DropDown.vue';
import ArrowButton from '@components/functional/ArrowButton';

describe('Dropdown component', () => {
	beforeEach(() => {
		jest.useFakeTimers();
		jest.clearAllTimers();
	});

	afterEach(() => {
		jest.clearAllTimers();
		jest.useRealTimers();
	});

	describe('toggling', () => {

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

		it('marks itself as open immediately upon starting to open', () => {
			const wrapper = shallowMount(DropDown, {
				stubs: {
					'arrow-button': true
				}
			});

			wrapper.vm.toggle();
			expect(wrapper.vm.isOpen).toBe(true);
		});
	});

	describe('rendering', () => {
		describe('button slot default', () => {
			it ('renders an arrow button', () => {
				const wrapper = shallowMount(DropDown, {
					propsData: {
						startOpen: true
					},
					stubs: {
						'arrow-button': ArrowButton
					},
					methods: {
						$_t: (str) => str
					}
				});

				expect(wrapper.contains(ArrowButton)).toBe(true);
			});

			it('binds open and closed to up and down on the arrow', () => {
				const arrowStub = {
					template: '<div/>',
					props: {
						direction: null
					},
				};

				const wrapper = shallowMount(DropDown, {
					components: {
						'arrow-button': arrowStub
					}
				});

				const arrow = wrapper.find(arrowStub);
				expect(arrow.props('direction')).toEqual('down');

				wrapper.setData({isOpen: true});
				expect(arrow.props('direction')).toEqual('up');
			});
		});
	});

	describe('with button slot content', () => {
		it('mounts with the proper scope', () => {

			const wrapper = shallowMount(DropDown, {
				scopedSlots: {
					button: '<button>{{props.isOpen ? "open" : "closed"}}</button>'
				}
			});

			const button = wrapper.find('button');
			expect(button.exists()).toBe(true);
			expect(button.text()).toEqual('closed');

			wrapper.find('.dropdown-button').trigger('click');
			expect(button.text()).toEqual('open');
		});
	});
});
