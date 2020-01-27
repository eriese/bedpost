import ValidationProcessor from '@modules/validation/ValidationProcessor';
import Vuelidate from 'vuelidate';
import {mount, createLocalVue} from '@vue/test-utils';
import {required} from 'vuelidate/lib/validators';

let localVue;
const component = {
	template: '<div/>',
	props: {
		validate: Object,
		adlValidation: Object,
		value: Object,
		refs: Object,
	},
	data() {
		return {...this.value};
	},
	validations() {
		return new ValidationProcessor(this.validate, [], this.value, this.refs, this.adlValidation).process();
	},
};

const mountWrapper = (propsData) => {
	const wrapper = mount(component, {
		propsData,
		localVue,
	});

	return [wrapper.vm.$v, wrapper];
};

beforeEach(() => {
	localVue = createLocalVue();
	localVue.use(Vuelidate);
});

describe('ValidationProcessor class', () => {
	describe ('constructor', () => {
		it('defaults to an empty object for given validators', () => {
			const processor = new ValidationProcessor();
			expect(processor.givenValidators).toEqual({});
		});

		it('defaults to an empty array for starting path', () => {
			const processor = new ValidationProcessor();
			expect(processor.startingPath).toEqual([]);
		});

		it('defaults to an empty object for given fields', () => {
			const processor = new ValidationProcessor();
			expect(processor.givenFields).toEqual({});
		});
	});

	describe ('process', () => {
		it('returns a configuration object to be used by Vuelidate', () => {
			const validators = {password: [['presence']]};
			const fields = {password: null};

			const result = new ValidationProcessor(validators, [], fields).process();

			expect(result).toMatchObject({
				password: {
					submitted: expect.any(Function),
					blank: required
				}
			});
		});
	});

	it('adds a submitted validator to every field, even if the field has no other validators', () => {
		const [$v] = mountWrapper({
			validate: {
				password: [['length', {minimum: 7}]]
			},
			value: {
				name: null,
				password: null,
			}
		});

		expect($v.name).not.toBeUndefined();
		expect($v.name.submitted).toBe(true);
		expect($v.password.submitted).toBe(true);
	});

	it('adds an email validator to any field containing "email", even if the field has no other validators', () => {
		const [$v] = mountWrapper({
			validate: {
				email: [['presence']],
			},
			value: {
				email: 'non-email string',
				otherEmail: 'email@email.com'
			}
		});

		expect($v.email.email).toBe(false);
		expect($v.otherEmail.email).toBe(true);
	});

	it('can handle a single-level object', () => {
		const [$v] = mountWrapper({
			validate: {
				password: [['length', {minimum: 7}]],
				name: [['length', {minimum: 7}]],
			},
			value: {
				name: null,
				password: null,
			},
		});

		expect($v.name).not.toBeUndefined();
		expect($v.password).not.toBeUndefined();
	});

	it('can handle nested objects', () => {
		const [$v] = mountWrapper({
			validate: {
				password: [['length', {minimum: 7}]],
				name: {
					first: [['length', {minimum: 7}]],
					last: [['length', {maximum: 47}]],
				},
			},
			value: {
				name: {
					first: null,
					last: null,
				},
				password: null,
			},
		});

		expect($v.name).not.toBeUndefined();
		expect($v.name.first).not.toBeUndefined();
		expect($v.name.last).not.toBeUndefined();
		expect($v.password).not.toBeUndefined();
	});

	it('it looks in validators for additional validations', () => {
		const [$v] = mountWrapper({
			validate: {
				password: [['presence']]
			},
			value: {
				name: null
			}
		});

		expect($v.password).not.toBeUndefined();
		expect($v.password.blank).toBe(false);
	});

	describe('with a field that validates a confirmation', () => {
		it('if the confirmation field is also on the form, it adds a sameAs validator to the confirmation field', () => {
			const [$v, wrapper] = mountWrapper({
				validate: {
					password: [['confirmation', {}]]
				},
				value: {
					password: null,
					password_confirmation: null
				}
			});

			expect($v.password_confirmation.confirmation).toBe(true);

			wrapper.setData({password: 'something'});

			expect($v.password_confirmation.confirmation).toBe(false);
		});

		it('if the confirmation field is not on the form, there are no validations for the confirmation field', () => {
			const [$v] = mountWrapper({
				validate: {
					password: [['confirmation', {}]]
				},
				value: {
					password: null,
				}
			});

			expect($v.password_confirmation).toBeUndefined();
		});
	});

	describe('validator transformations', () => {
		it('keys presence validations with "blank"', () => {
			const [$v] = mountWrapper({
				validate: {
					name: [['presence']]
				},
				value: {
					name: null
				}
			});

			expect($v.name.blank).toBe(false);
		});

		it('keys length validations that have a minimum with "too_short"', () => {
			const [$v] = mountWrapper({
				validate: {
					name: [['length', {minimum: 7}]]
				},
				value: {
					name: '1'
				}
			});

			expect($v.name.too_short).toBe(false);
		});

		it('keys length validations that have a maximum with "too_long"', () => {
			const [$v] = mountWrapper({
				validate: {
					name: [['length', {maximum: 7}]]
				},
				value: {
					name: '12345678'
				}
			});

			expect($v.name.too_long).toBe(false);
		});

		it('keys require_unless_valid validations as one_of', () => {
			const [$v] = mountWrapper({
				validate: {
					name: [['require_unless_valid', {path: 'lastName'}]],
				},
				value: {
					name: '',
					lastName: ''
				}
			});

			expect($v.name.one_of).toBe(false);
			expect($v.name.$params.one_of.locator).toEqual('lastName');
		});

		it('keys uniqueness validations with taken', () => {
			jest.mock('axios');

			const [$v] = mountWrapper({
				validate: {
					name: [['uniqueness']],
				},
				value: {
					name: ''
				}
			});

			expect($v.name.taken).not.toBeUndefined();
		});

		it('validates an acceptance group against the un-grouped fieldname', () => {
			const [$v] = mountWrapper({
				validate: {
					name_group: [['acceptance']]
				},
				value: {
					name: false
				}
			});

			expect($v.name_group.acceptance).toBe(false);
			expect($v.name_group.$params.acceptance.field).toEqual('name');
		});
	});

	describe ('responding to changes in the form', () => {
		it('skips fields that are not in refs if refs are given', () => {
			const [$v] = mountWrapper({
				value: {
					name1: '',
					name2: ''
				},
				refs: {
					name1: true
				}
			});

			expect($v.name1).not.toBeUndefined();
			expect($v.name2).toBeUndefined();
		});
	});
});
