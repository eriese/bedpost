import {mount, createLocalVue} from '@vue/test-utils';
import FormStepComponent from '@components/stepper/FormStepComponent.vue';

function mountWrapper(slotContent, localVue, optional) {
	let mountOptions = {
		scopedSlots: {
			default: slotContent || '<div/>'
		},
		propsData: {
			optional: optional,
		},
		methods: {
			$_t: jest.fn()
		},
	};

	if (localVue) { mountOptions.localVue = localVue; }

	return mount(FormStepComponent, mountOptions);
}
describe('Form Step Component', () => {
	describe('checkComplete', () => {
		it('returns true if the step is optional', () => {
			const wrapper = mountWrapper(null, null, true);

			expect(wrapper.vm.checkComplete()).toBe(true);
		});

		const fieldComponent = {
			name: 'field_errors',
			data() {
				return {
					focusCalls: 0
				};
			},
			methods: {
				setFocus() {
					this.focusCalls++;
				}
			},
			render(h) {
				return h('div');
			}
		};

		const localVue = createLocalVue();
		localVue.component('field-errors', fieldComponent);

		it('returns false if one of its children is not complete', () => {
			const wrapper = mountWrapper('<div><field-errors/><field-errors/></div>', localVue);

			wrapper.setData({completes: [true, false]});
			expect(wrapper.vm.checkComplete()).toBe(false);
		});

		it('calls setFocus on the first incomplete child', () => {
			const wrapper = mountWrapper('<div><field-errors/><field-errors/></div>', localVue);

			wrapper.setData({completes: [true, false]});
			wrapper.vm.checkComplete();

			const fields = wrapper.vm.fields;
			expect(fields[0].focusCalls).toBe(0);
			expect(fields[1].focusCalls).toBe(1);
		});

		it('does not call setFocus on the first incomplete child if checkComplete is called with false', () => {
			const wrapper = mountWrapper('<div><field-errors/><field-errors/></div>', localVue);

			wrapper.setData({completes: [true, false]});
			wrapper.vm.checkComplete(false);

			const fields = wrapper.vm.fields;
			expect(fields[1].focusCalls).toBe(0);
		});

		it('calls setFocus on the first child if there are no imcomplete fields and checkComplete is called with true', () => {
			const wrapper = mountWrapper('<div><field-errors/><field-errors/></div>', localVue);

			wrapper.setData({completes: [true, true]});
			wrapper.vm.checkComplete(true);

			const fields = wrapper.vm.fields;
			expect(fields[0].focusCalls).toBe(1);
			expect(fields[1].focusCalls).toBe(0);
		});

		it('returns true if there are no incomplete fields', () => {
			const wrapper = mountWrapper('<div><field-errors/><field-errors/></div>', localVue);

			wrapper.setData({completes: [true, true]});
			expect(wrapper.vm.checkComplete()).toBe(true);
		});
	});
});
