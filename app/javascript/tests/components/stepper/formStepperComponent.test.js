import {mount, createLocalVue} from '@vue/test-utils';
import FormStepperComponent from '@components/stepper/FormStepperComponent.vue';

describe('Form Stepper Component', () => {
	describe('mounted', () => {
		it('adds a listener to process its children when a new step is added', () => {
			const processChildren = jest.fn();
			const wrapper = mount(FormStepperComponent, {
				methods: {
					processChildren,
					$_t: jest.fn()
				}
			});

			wrapper.vm.$emit('step-added');
			expect(processChildren).toHaveBeenCalled();
		});

		it('adds a listener to process its children when a step is removed', () => {
			const processChildren = jest.fn();
			const wrapper = mount(FormStepperComponent, {
				methods: {
					processChildren,
					$_t: jest.fn()
				}
			});

			wrapper.vm.$emit('step-removed');
			expect(processChildren).toHaveBeenCalled();
		});

		it('does not process its children until they are mounted', () => {
			const processChildren = jest.fn();
			const wrapper = mount(FormStepperComponent, {
				methods: {
					processChildren,
					$_t: jest.fn()
				}
			});

			expect(processChildren).not.toHaveBeenCalled();

			wrapper.vm.$emit('lazy-child-present');
			return wrapper.vm.$nextTick().then(() => {
				expect(processChildren).toHaveBeenCalled();
			});
		});

		it('does not emit that it is mounted until its children are mounted', () => {
			const processChildren = jest.fn();
			const wrapper = mount(FormStepperComponent, {
				methods: {
					processChildren,
					$_t: jest.fn()
				}
			});

			expect(wrapper.emitted('stepper-mounted')).toBeFalsy();

			wrapper.vm.$emit('lazy-child-present');
			return wrapper.vm.$nextTick().then(() => {
				expect(wrapper.emitted('stepper-mounted')).toBeTruthy();
			});
		});
	});

	describe('processChildren', () => {
		function setupWrapper(slotContent) {
			const localVue = createLocalVue();

			const FormStep = {
				name: 'form_step',
				render: (h) => h('div'),
				data() {
					return {
						index: 0
					};
				},
				methods: {
					checkComplete: () => true
				}
			};

			const OtherChild = {
				name: 'other_child',
				render: (h) => h('div'),
			};

			localVue.component('form-step', FormStep);
			localVue.component('other-child', OtherChild);

			return mount(FormStepperComponent, {
				methods: {
					$_t: jest.fn()
				},
				scopedSlots: {
					default: slotContent
				},
				stubs: ['arrow-button'],
				localVue,
			});
		}

		it('sets the proper index on the child steps, ignoring other children', () => {
			const wrapper = setupWrapper('<div><form-step/><other-child/><form-step/><form-step/></div>');

			wrapper.vm.processChildren(wrapper.vm.$children);

			expect(wrapper.vm.$children[0].index).toBe(0);
			expect(wrapper.vm.$children[2].index).toBe(1);
			expect(wrapper.vm.$children[3].index).toBe(2);
		});

		it('keeps track of the indexes of its children that are steps, and how many there are', () => {
			const wrapper = setupWrapper('<div><form-step/><other-child/><form-step/><form-step/></div>');

			wrapper.vm.processChildren(wrapper.vm.$children);

			expect(wrapper.vm.indexes).toEqual([0,2,3]);
			expect(wrapper.vm.numSteps).toBe(3);
		});

		it('calls processIndex after processing the children', () => {
			const processIndex = jest.fn();
			const wrapper = mount(FormStepperComponent, {
				methods: {
					$_t: jest.fn(),
					setStepComplete: jest.fn(),
					processIndex
				}
			});

			wrapper.vm.processChildren([]);
			expect(processIndex).toHaveBeenCalled();
		});
	});

	describe('findNext', () => {
		function setupWrapper(completes) {
			const localVue = createLocalVue();

			const FormStep = {
				name: 'form_step',
				render: (h) => h('div'),
				methods: {
					checkComplete: (index) => completes[index]
				}
			};

			localVue.component('form-step', FormStep);
			const slotContent = '<div>' + '<form-step/>'.repeat(completes.length) + '</div>';
			return mount(FormStepperComponent, {
				data() {
					return {
						completes
					};
				},
				methods: {
					$_t: jest.fn()
				},
				scopedSlots: {
					default: slotContent
				},
				stubs: ['arrow-button'],
				localVue,
			});
		}

		describe('finds the next step that is incomplete', () => {
			it('starts at the current index', () => {
				const completes = [false, true, true, false];
				const wrapper = setupWrapper(completes);
				const flik = {
					selectCell: jest.fn()
				};

				wrapper.vm.processChildren(wrapper.vm.$children);

				wrapper.setData({
					flik,
					completes,
					curIndex: 1,
				});

				wrapper.vm.findNext();
				expect(flik.selectCell).toHaveBeenCalledWith(3);
			});

			it('loops around to the beginning if there are none following the current index', () => {
				const completes = [false, false, true, true];
				const wrapper = setupWrapper(completes);
				const flik = {
					selectCell: jest.fn()
				};

				wrapper.vm.processChildren(wrapper.vm.$children);

				wrapper.setData({
					flik,
					completes,
					curIndex: 2,
				});

				wrapper.vm.findNext();
				expect(flik.selectCell).toHaveBeenCalledWith(0);
			});
		});
	});
});
