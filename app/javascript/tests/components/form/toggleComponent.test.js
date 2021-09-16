import {mount, createLocalVue} from '@vue/test-utils';
import Toggle from '@components/form/ToggleComponent.vue';

function mountLocal(component, args) {
	const $_t = jest.fn();
	const localVue = createLocalVue();
	localVue.mixin({
		methods: {
			$_t
		}
	});

	return [mount(component, {...args, localVue}), $_t];
}

describe('Toggle Component', () => {
	it('has default symbols -/+', () => {
		const [wrapper] = mountLocal(Toggle);
		expect(wrapper.vm.symbols).toEqual(['-', '+']);
	});

	it('has default values true/false', () => {
		const [wrapper] = mountLocal(Toggle);
		expect(wrapper.vm.vals).toEqual([true, false]);
	});

	it('chooses its symbol based on the matching index in the vals array', () => {
		const symbols = ['a', 'b'],
			vals = [1, 2];
		const [wrapper] = mountLocal(Toggle, {
			propsData: {
				symbols,
				vals,
				val: 2
			},
		});

		expect(wrapper.vm.toggleState).toEqual('b');
	});

	describe('doToggle', () => {
		it('emits a toggle-event with the field name, the new value, and whether there is a field to clear', () => {
			const symbols = ['a', 'b'],
				vals = [1, 2],
				field = 'aField';
			const [wrapper] = mountLocal(Toggle, {
				propsData: {
					symbols,
					vals,
					val: 1,
				},
				attrs: {
					field
				},
			});

			wrapper.vm.doToggle();
			const emitted = wrapper.emitted()['toggle-event'];
			expect(emitted).toBeTruthy();
			expect(emitted[0]).toEqual([field, 2, null]);
		});

		it('emits a new value from the beginning of the vals array if the current value is at the end of it', () => {
			const symbols = ['a', 'b'],
				vals = [1, 2];
			const [wrapper] = mountLocal(Toggle, {
				propsData: {
					symbols,
					vals,
				},
			});

			const vm = wrapper.vm;

			wrapper.setProps({val: vm.vals[vm.vals.length - 1]});
			wrapper.vm.doToggle();

			const emitted = wrapper.emitted()['toggle-event'];
			expect(emitted[0][1]).toBe(vm.vals[0]);
		});

		describe('with a clear value', () => {
			it('emits the clear value if no clearOn prop is defined', () => {
				const clear = 'doClear';
				const [wrapper] = mountLocal(Toggle, {
					propsData: {
						clear
					},
				});

				wrapper.vm.doToggle();
				expect(wrapper.emitted()['toggle-event'][0][2]).toEqual(clear);
			});

			it('emits the clear value if a clearOn prop is defined and the next value is included in it', () => {
				const clear = 'doClear',
					clearOn = ['b'],
					val = 'a',
					vals = ['b', 'a'];

				const [wrapper] = mountLocal(Toggle, {
					propsData: {
						clear,
						clearOn,
						vals,
						val,
					}
				});

				wrapper.vm.doToggle();
				expect(wrapper.emitted()['toggle-event'][0][2]).toEqual(clear);
			});

			it('does not emit the clear value if a clearOn prop is defined and the next value is not included in it', () => {
				const clear = 'doClear',
					clearOn = ['b'],
					val = 'b',
					vals = ['b', 'a'];

				const [wrapper] = mountLocal(Toggle, {
					propsData: {
						clear,
						clearOn,
						vals,
						val,
					}
				});

				wrapper.vm.doToggle();
				expect(wrapper.emitted()['toggle-event'][0][2]).toBeNull();
			});
		});
	});

	describe('expanded', () => {
		it('marks itself as expanded if it is expandable and the value is truthy', () => {
			const [wrapper] = mountLocal(Toggle, {
				propsData: {
					expandable: true,
					val: true
				},
			});

			expect(wrapper.vm.expanded).toEqual('true');
			expect(wrapper.html()).toContain('aria-expanded="true"');
		});

		it('marks itself as not expanded if it is expandable and the value is falsy', () => {
			const [wrapper] = mountLocal(Toggle, {
				propsData: {
					expandable: true,
					val: false
				},
			});

			wrapper.setProps({val: false});
			expect(wrapper.vm.expanded).toEqual('false');
			expect(wrapper.html()).toContain('aria-expanded="false"');
		});

		it('does not have an aria-expanded attribute if it is not expandable', () => {
			const [wrapper] = mountLocal(Toggle);
			expect(wrapper.html()).not.toContain('aria-expanded');
		});
	});

	describe('toggleState', () => {
		it('allows a constant state label', () => {
			const label = 'label';
			const [wrapper] = mountLocal(Toggle, {
				propsData: {
					symbols: label,
					val: true,
				},
			});

			expect(wrapper.vm.toggleState).toEqual(label);

			wrapper.setProps({val: false});
			expect(wrapper.vm.toggleState).toEqual(label);
		});

		it('will select the symbols array value at the same index as the current value in the vals array', () => {
			const symbols = ['a', 'b', 'c'];
			const vals = ['val1', 'val2', 'val3'];

			const [wrapper] = mountLocal(Toggle, {
				propsData: {
					symbols,
					vals,
					val: vals[1]
				},
			});

			expect(wrapper.vm.toggleState).toEqual(symbols[1]);
			wrapper.setProps({val: vals[2]});

			return wrapper.vm.$nextTick(() => {
				expect(wrapper.vm.toggleState).toEqual(symbols[2]);
			});

		});
	});

	describe('translate', () => {
		it('accepts a boolean, which will cause it to translate the key', () => {
			const symbols = ['a', 'b'], vals = [1, 2];

			const [, $_t] = mountLocal(Toggle, {
				propsData: {
					symbols,
					vals,
					translate: true,
					val: 1,
				}
			});

			expect($_t).toHaveBeenCalledWith('a');
		});

		it('accepts a string, which will be used as the scope to translate the key', () => {
			const symbols = ['a', 'b'], vals = [1, 2], translate= 'scope';

			const [, $_t] = mountLocal(Toggle, {
				propsData: {
					symbols,
					vals,
					translate,
					val: 1,
				}
			});

			expect($_t).toHaveBeenCalledWith('a', {scope: translate});
		});
	});
});
