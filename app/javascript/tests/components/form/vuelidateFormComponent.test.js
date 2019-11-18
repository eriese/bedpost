import {mount, createLocalVue} from "@vue/test-utils";
import Vuelidate from 'vuelidate'
import VuelidateForm from "@components/form/VuelidateFormComponent.js";
import {onTransitionTriggered} from "@modules/transitions";

jest.mock('@modules/transitions');

let localVue;
const mountWrapper = (propsData) => {
	return mount(VuelidateForm, {
		propsData,
		localVue,
		scopedSlots: {
			default: "<div/>"
		},
	})
}
beforeEach(() => {
	localVue = createLocalVue();
	localVue.use(Vuelidate)
})

describe("VuelidateForm Component", () => {
	describe("methods", () => {
		describe("validateForm", () => {
			describe("with an invalid form", () => {
				test("it stops the form from submitting", () => {
					const wrapper = mountWrapper({
						validate: {
							name: [["presence"]],
						},
						value: {
							name: null,
						}
					});

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					}

					wrapper.vm.validateForm(event);
					expect(event.preventDefault).toHaveBeenCalled();
					expect(event.stopPropagation).toHaveBeenCalled();
				})

				test("it focuses the first invalid child component", () => {
					const setFocus = jest.fn()
					let childIsValid = false;
					const isValid = jest.fn().mockImplementation(() => {
						childIsValid = !childIsValid;
						return childIsValid;
					})

					const childStub = {
						methods: {
							isValid,
							setFocus
						},
						render(h) {
							h("div")
						}
					}

					localVue.component('child', childStub)

					const wrapper = mount(VuelidateForm, {
						localVue,
						propsData: {
							validate: {
								name: [["presence"]],
							},
							value: {
								name: null,
							}
						},
						scopedSlots: {
							default: "<div><child></child><child></child></div>"
						}
					});

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					}

					wrapper.vm.validateForm(event);
					expect(isValid).toHaveBeenCalledTimes(2);
					expect(setFocus).toHaveBeenCalled();
				})
			})

			describe("with a valid form", () => {
				test("it does not stop the form from submitting", () => {
					const wrapper = mountWrapper({
						validate: {
							name: [["presence"]],
						},
						value: {
							name: "here",
						}
					});

					const event = {
						preventDefault: jest.fn(),
						stopPropagation: jest.fn()
					}

					wrapper.vm.validateForm(event);
					expect(event.preventDefault).not.toHaveBeenCalled();
					expect(event.stopPropagation).not.toHaveBeenCalled();
				})

				test("it clears out existing submission errors", () => {
					const wrapper = mountWrapper({
						validate: {
							name: [["presence"]],
						},
						value: {
							name: "something",
						},
						error: {
							name: "no good"
						}
					});

					expect(wrapper.vm.$v.formData.name.submitted).toBe(false);
					wrapper.vm.formData.name = "something else";

					wrapper.vm.validateForm();
					expect(wrapper.vm.submissionError).toEqual({});
					expect(wrapper.vm.$v.formData.name.submitted).toBe(true);
				})
			})
		})

		describe("handleError", () => {
			test("it sets the submission errors based on the response", () => {
				const wrapper = mountWrapper({
					validate: {
						name: [["presence"]],
					},
					value: {
						name: "something",
					},
				});

				const error = {
					detail: [{
						errors: {
							name: "no good"
						}
					}, 500, {}],
				};

				expect(wrapper.vm.$v.formData.name.submitted).toBe(true);

				wrapper.vm.handleError(error);
				expect(wrapper.vm.submissionError).toEqual(error.detail[0].errors);
				expect(wrapper.vm.$v.formData.name.submitted).toBe(false);
			})
		})

		describe("toggle", () => {
			test("with a clear value of true, it clears the value at the same path as the toggle name", () => {
				const wrapper = mountWrapper({
					startToggles: {
						name: false,
					},
					value: {
						name: "something",
					},
				});

				const vm = wrapper.vm;
				vm.toggle("name", true, true)
				expect(vm.toggles.name).toBe(true)
				expect(vm.formData.name).toBe(null)
			})

			test("with a string clear value, it clears the value at that path", () => {
				const wrapper = mountWrapper({
					startToggles: {
						name: false,
					},
					value: {
						clearField: "something",
					},
				});

				const vm = wrapper.vm;
				vm.toggle("name", true, "clearField")
				expect(vm.toggles.name).toBe(true)
				expect(vm.formData.clearField).toBe(null)
			})
		})
	})

	describe("validations", () => {
		test("it adds a submitted validator to every field, even if the field has no other validators", () => {
			const wrapper = mountWrapper({
				validate: {
					password: [["length", {minimum: 7}]]
				},
				value: {
					name: null,
					password: null,
				}
			});

			const $vFormData = wrapper.vm.$v.formData;
			expect($vFormData.name).not.toBe(undefined)
			expect($vFormData.name.submitted).toBe(true);
			expect($vFormData.password.submitted).toBe(true);
		})

		test("it adds an email validator to any field containing 'email', even if the field has no other validators", () => {
			const wrapper = mountWrapper({
				validate: {
					email: [["presence"]],
				},
				value: {
					email: "non-email string",
					otherEmail: "email@email.com"
				}
			});

			const $vFormData = wrapper.vm.$v.formData;
			expect($vFormData.email.email).toBe(false)
			expect($vFormData.otherEmail.email).toBe(true);
		})

		test("it can handle a single-level object", () => {
			const wrapper = mountWrapper({
				validate: {
					password: [["length", {minimum: 7}]],
					name: [["length", {minimum: 7}]],
				},
				value: {
					name: null,
					password: null,
				},
			})

			const $vFormData = wrapper.vm.$v.formData;
			expect($vFormData.name).not.toBe(undefined);
			expect($vFormData.password).not.toBe(undefined);
		})

		test("it can handle nested objects", () => {
			const wrapper = mountWrapper({
				validate: {
					password: [["length", {minimum: 7}]],
					name: {
						first: [["length", {minimum: 7}]],
						last: [["length", {maximum: 47}]],
					},
				},
				value: {
					name: {
						first: null,
						last: null,
					},
					password: null,
				},
			})

			const $vFormData = wrapper.vm.$v.formData;
			expect($vFormData.name).not.toBe(undefined);
			expect($vFormData.name.first).not.toBe(undefined);
			expect($vFormData.name.last).not.toBe(undefined);
			expect($vFormData.password).not.toBe(undefined);
		})

		describe("with a field that validates a confirmation", () => {
			test("if the confirmation field is also on the form, it adds a sameAs validator to the confirmation field", () => {
				const wrapper = mountWrapper({
					validate: {
						password: [["confirmation", {}]]
					},
					value: {
						password: null,
						password_confirmation: null
					}
				})

				expect(wrapper.vm.$v.formData.password_confirmation.confirmation).toBe(true)

				wrapper.vm.formData.password = "something";

				expect(wrapper.vm.$v.formData.password_confirmation.confirmation).toBe(false);
			})

			test("if the confirmation field is not on the form, there are no validations for the confirmation field", () => {
				const wrapper = mountWrapper({
					validate: {
						password: [["confirmation", {}]]
					},
					value: {
						password: null,
					}
				})

				expect(wrapper.vm.$v.formData.password_confirmation).toBe(undefined)
			})
		})

		describe("validator transformations", () => {
			test("it keys presence validations with 'blank'", () => {
				const wrapper = mountWrapper({
					validate: {
						name: [["presence"]]
					},
					value: {
						name: null
					}
				})
				const $vFormData = wrapper.vm.$v.formData;
				expect($vFormData.name.blank).toBe(false);
			})

			test("it keys length validations that have a minimum with 'too_short'", () => {
				const wrapper = mountWrapper({
					validate: {
						name: [["length", {minimum: 7}]]
					},
					value: {
						name: "1"
					}
				})
				const $vFormData = wrapper.vm.$v.formData;
				expect($vFormData.name.too_short).toBe(false);
			})

			test("it keys length validations that have a maximum with 'too_long'", () => {
				const wrapper = mountWrapper({
					validate: {
						name: [["length", {maximum: 7}]]
					},
					value: {
						name: "12345678"
					}
				})
				const $vFormData = wrapper.vm.$v.formData;
				expect($vFormData.name.too_long).toBe(false);
			})
		})
	})
})
