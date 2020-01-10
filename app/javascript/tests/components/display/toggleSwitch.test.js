import ToggleSwitch from '@components/display/ToggleSwitch.vue';
import {mount} from '@vue/test-utils';

describe('Toggle Switch Component', () => {
	describe('toggleState', () => {
		it('does not track toggle state', () => {
			const wrapper = mount(ToggleSwitch);

			expect(wrapper.vm.toggleState).toEqual('');
		});
	});

	describe('doToggle', () => {
		it('emits the value at the given index', () => {
			const wrapper = mount(ToggleSwitch, {
				attrs: {
					field: 'field'
				}
			});
			wrapper.vm.doToggle(0);
			expect(wrapper.emitted('toggle-event')[0]).toEqual(['field', wrapper.vm.vals[0], null]);
		});

		it('is attached to the buttons', () => {
			const doToggle = jest.fn();
			const wrapper = mount(ToggleSwitch, {
				attrs: {
					field: 'field'
				},
				propsData: {
					vals: ['0', '1', '2', '3'],
					symbols: ['zero', 'one', 'two', 'three']
				},
				methods: {
					doToggle
				}
			});

			const buttons = wrapper.findAll('button');
			expect(buttons).toHaveLength(4);

			buttons.at(2).trigger('click');

			expect(doToggle).toHaveBeenCalledWith(2);
		});
	});

	describe('displayStrings', () => {
		it('creates a map of the symbols when translate is false', () => {
			const symbols = ['zero', 'one', 'two', 'three'];
			const wrapper = mount(ToggleSwitch, {
				attrs: {
					field: 'field'
				},
				propsData: {
					vals: ['0', '1', '2', '3'],
					symbols
				},
			});

			expect(wrapper.vm.displayStrings).toEqual(symbols);
		});

		it('creates a map of translated symbols when translate is true', () => {
			const symbols = ['zero', 'one', 'two', 'three'];
			const $_t = (s) => `t_${s}`;
			const wrapper = mount(ToggleSwitch, {
				attrs: {
					field: 'field'
				},
				propsData: {
					vals: ['0', '1', '2', '3'],
					symbols,
					translate: true,
				},
				methods: {
					$_t
				}
			});

			expect(wrapper.vm.displayStrings).toEqual(symbols.map($_t));
		});

		it('creates a map of translated symbols using translate as a key when translate is a string', () => {
			const symbols = ['zero', 'one', 'two', 'three'];
			const $_t = (s, o) => `t_${s}_${o.scope}`;
			const wrapper = mount(ToggleSwitch, {
				attrs: {
					field: 'field'
				},
				propsData: {
					vals: ['0', '1', '2', '3'],
					symbols,
					translate: 'trans',
				},
				methods: {
					$_t
				}
			});

			expect(wrapper.vm.displayStrings).toEqual(symbols.map((s) => $_t(s, {scope: 'trans'})));
		});
	});
});
