import {mount, createLocalVue} from '@vue/test-utils';
import Vuelidate from 'vuelidate';
import VuelidateForm from '@components/form/VuelidateFormComponent.js';

jest.mock('@modules/transitions');

let localVue;
const mountWrapper = (propsData) => {
	return mount(VuelidateForm, {
		propsData,
		localVue,
		scopedSlots: {
			default: '<div/>'
		},
	});
};

beforeEach(() => {
	localVue = createLocalVue();
	localVue.use(Vuelidate);
});

describe('VuelidateForm Component', () => {
	describe('methods', () => {
		describe('validateForm', () => {
			describe('with an invalid form', () => {
				it('it stops the form from submitting', () => {
					const wrapper = mountWrapper({
						validate: {
							name: [['presence']],
						},
						value: {
							name: null,
						}
					});

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					};

					wrapper.vm.validateForm(event);
					expect(event.preventDefault).toHaveBeenCalled();
					expect(event.stopPropagation).toHaveBeenCalled();
				});

				it('it focuses the first invalid child component', () => {
					const setFocus = jest.fn();
					let childIsValid = false;
					const isValid = jest.fn().mockImplementation(() => {
						childIsValid = !childIsValid;
						return childIsValid;
					});

					const childStub = {
						methods: {
							isValid,
							setFocus
						},
						render(h) {
							h('div');
						}
					};

					localVue.component('child', childStub);

					const wrapper = mount(VuelidateForm, {
						localVue,
						propsData: {
							validate: {
								name: [['presence']],
							},
							value: {
								name: null,
							}
						},
						scopedSlots: {
							default: '<div><child></child><child></child></div>'
						}
					});

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					};

					wrapper.vm.validateForm(event);
					expect(isValid).toHaveBeenCalledTimes(2);
					expect(setFocus).toHaveBeenCalled();
				});
			});

			describe('with a valid form', () => {
				it('it does not stop the form from submitting', () => {
					const wrapper = mountWrapper({
						validate: {
							name: [['presence']],
						},
						value: {
							name: 'here',
						}
					});

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					};

					wrapper.vm.validateForm(event);
					expect(event.preventDefault).not.toHaveBeenCalled();
					expect(event.stopPropagation).not.toHaveBeenCalled();
				});

				it('it clears out existing submission errors', () => {
					const wrapper = mountWrapper({
						validate: {
							name: [['presence']],
						},
						value: {
							name: 'something',
						},
						error: {
							name: 'no good'
						}
					});

					expect(wrapper.vm.$v.formData.name.submitted).toBe(false);
					wrapper.vm.formData.name = 'something else';

					wrapper.vm.validateForm();
					expect(wrapper.vm.submissionError).toEqual({});
					expect(wrapper.vm.$v.formData.name.submitted).toBe(true);
				});
			});

			describe('with a stepper', () => {
				it('it does not submit if the stepper is not ready, even if the form is valid', () => {
					const wrapper = mountWrapper({
						validate: {
							name: [['presence']],
						},
						value: {
							name: 'something',
						},
					});

					const stepper = {
						allReady: () => false,
						findNext: jest.fn()
					};

					wrapper.vm.slotScope.addStepper(stepper);

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					};

					wrapper.vm.validateForm(event);
					expect(event.preventDefault).toHaveBeenCalled();
					expect(event.stopPropagation).toHaveBeenCalled();
					expect(stepper.findNext).toHaveBeenCalled();
				});

				it('it submits if the stepper is ready and the form is valid', () => {
					const wrapper = mountWrapper({
						validate: {
							name: [['presence']],
						},
						value: {
							name: 'something',
						},
					});

					const stepper = {
						allReady: () => true,
						findNext: jest.fn()
					};

					wrapper.vm.slotScope.addStepper(stepper);

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					};

					wrapper.vm.validateForm(event);
					expect(event.preventDefault).not.toHaveBeenCalled();
					expect(event.stopPropagation).not.toHaveBeenCalled();
					expect(stepper.findNext).not.toHaveBeenCalled();
				});
			});
		});

		describe('handleError', () => {
			it('it sets the submission errors based on the response', () => {
				const wrapper = mountWrapper({
					validate: {
						name: [['presence']],
					},
					value: {
						name: 'something',
					},
				});

				const error = {
					detail: [{
						errors: {
							name: 'no good'
						}
					}, 500, {}],
				};

				expect(wrapper.vm.$v.formData.name.submitted).toBe(true);

				wrapper.vm.handleError(error);
				expect(wrapper.vm.submissionError).toEqual(error.detail[0].errors);
				expect(wrapper.vm.$v.formData.name.submitted).toBe(false);
			});
		});

		describe('toggle', () => {
			it('with a clear value of true, it clears the value at the same path as the toggle name', () => {
				const wrapper = mountWrapper({
					startToggles: {
						name: false,
					},
					value: {
						name: 'something',
					},
				});

				const vm = wrapper.vm;
				vm.toggle('name', true, true);
				expect(vm.toggles.name).toBe(true);
				expect(vm.formData.name).toBeNull();
			});

			it('with a string clear value, it clears the value at that path', () => {
				const wrapper = mountWrapper({
					startToggles: {
						name: false,
					},
					value: {
						clearField: 'something',
					},
				});

				const vm = wrapper.vm;
				vm.toggle('name', true, 'clearField');
				expect(vm.toggles.name).toBe(true);
				expect(vm.formData.clearField).toBeNull();
			});
		});
	});

	describe('validations', () => {
		describe('adlValidations', () => {
			it('is the basis of the generated validations', () => {
				const adlValidations = {
					password: {
						too_long: (v) => v > 5
					}
				};

				const wrapper = mount(VuelidateForm, {
					data() {
						return {
							adlValidations
						};
					},
					propsData: {
						value: {
							password: null,
						},
					},
					localVue,
					scopedSlots: {
						default: '<div/>'
					},
				});

				const $vFormData = wrapper.vm.$v.formData;
				expect($vFormData.password.too_long).not.toBeUndefined();
				expect($vFormData.password.submitted).not.toBeUndefined();
			});

			it('updates the $v object when it is changed', () => {
				const wrapper = mountWrapper({
					value: {
						name: null,
					},
				});

				const oldKeys = Object.keys(wrapper.vm.$v.formData.name);

				wrapper.setData({
					adlValidations: {
						name: {
							too_long: (v) => v > 5
						}
					}
				});
				const newKeys = Object.keys(wrapper.vm.$v.formData.name);

				expect(newKeys).not.toEqual(oldKeys);

			});

			it('is updated via slotScope method addValidation', () => {
				const wrapper = mountWrapper({
					value: {
						name: null,
					},
				});

				const oldKeys = Object.keys(wrapper.vm.$v.formData.name);

				wrapper.vm.slotScope.addValidation('name', {too_long: (v) => v > 5});
				const newKeys = Object.keys(wrapper.vm.$v.formData.name);

				expect(newKeys).not.toEqual(oldKeys);
			});
		});
	});
});
