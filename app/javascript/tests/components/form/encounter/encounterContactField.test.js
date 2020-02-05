import {createLocalVue, mount} from '@vue/test-utils';
import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import EncounterContactField from '@components/form/encounter/EncounterContactField.vue';
import Vuelidate from 'vuelidate';
import ContactState from '@components/form/state/ContactState';

describe('Encounter Contact Field Component', () => {
	global.gon = {
		encounter_data: {
			contacts: {
				touched: {
					key: 'touched',
					inst_key: 'can_touch',
					inverse_inst: 'can_be_touched_by',
					inverse_key: 'touched_by',
					t_key: 'touched'
				},
				penetrated: {
					key: 'penetrated',
					inst_key: 'can_penetrate',
					inverse_inst: 'can_be_penetrated_by',
					inverse_key: 'penetrated_by',
					t_key: 'penetrated'
				}
			},
			instruments: {
				anus: {
					can_clean: true,
					conditions: null,
					has_fluids: true,
					name: 'anus',
					partner_name: 'ass',
					user_name: 'ass',
					user_override: 'anus_name',
					_id: 'anus'
				},
				hand: {
					can_clean: true,
					conditions: null,
					has_fluids: true,
					name: 'hand',
					partner_name: 'hand',
					user_name: 'hand',
					user_override: null,
					_id: 'hand'
				},
				tongue: {
					can_clean: true,
					conditions: null,
					has_fluids: true,
					name: 'tongue',
					partner_name: 'tongue',
					user_name: 'tongue',
					user_override: null,
					_id: 'tongue'
				}
			},
			possibles: {
				touched: [
					{
						contact_type: {
							inst_key: 'can_touch',
							inverse_inst: 'can_be_touched_by',
							key: 'touched',
							t_key: 'touched'
						},
						object_instrument_id: 'anus',
						self_possible: true,
						subject_instrument_id: 'hand',
						_id: 'pos1'
					},
					{
						contact_type: {
							inst_key: 'can_touch',
							inverse_inst: 'can_be_touched_by',
							key: 'touched',
							t_key: 'touched'
						},
						object_instrument_id: 'tongue',
						self_possible: true,
						subject_instrument_id: 'tongue',
						_id: 'pos3'
					},
					{
						contact_type: {
							inst_key: 'can_touch',
							inverse_inst: 'can_be_touched_by',
							key: 'touched',
							t_key: 'touched'
						},
						object_instrument_id: 'hand',
						self_possible: true,
						subject_instrument_id: 'tongue',
						_id: 'pos4'
					},
					{
						contact_type: {
							inst_key: 'can_touch',
							inverse_inst: 'can_be_touched_by',
							key: 'touched',
							t_key: 'touched'
						},
						object_instrument_id: 'anus',
						self_possible: true,
						subject_instrument_id: 'anus',
						_id: 'pos5'
					},
				],
				penetrated: [
					{
						contact_type: {
							key: 'penetrated',
							inst_key: 'can_penetrate',
							inverse_inst: 'can_be_penetrated_by',
							t_key: 'penetrated'
						},
						object_instrument_id: 'anus',
						self_possible: true,
						subject_instrument_id: 'hand',
						_id: 'pos2'
					}
				]
			},
			partnerPronoun: {
				obj_possessive: 'theirs',
				object: 'them',
				possessive: 'their',
				reflexive: 'themself',
				subject: 'they',
				_id: '5bdb87db72c3e67e31d1b542'
			},
			barriers: {},
			partner: {
				name: 'Alice',
				'pronoun_id': '5bdb87db72c3e67e31d1b542',
				anus_name: 'a_n',
				external_name: 'e_n',
				internal_name: 'i_n',
				can_penetrate: false
			},
		},
		dummy: {
			barriers: [],
			position: 1,
			object: 'partner',
			subject: 'user'
		}
	};

	const defaultProps = {
		baseName: 'encounter[contacts_attributes]',
	};

	const wrapperComponent = {
		template: '<encounter-contact-field v-bind="fieldProps" :state="state" :$v="fieldV" v-model="value[0]"/>',
		props: {
			fieldProps: Object,
			value: Array,
		},
		components: {
			'encounter-contact-field': EncounterContactField,
		},
		data() {
			return {
				givenValidation: {},
				state: null
			};
		},
		validations() {
			return {value: this.givenValidation};
		},
		computed: {
			fieldV() {
				return this.$v.value.$each && this.$v.value.$each.$iter[0];
			}
		},
		methods: {
			addValidation(key, validation) {
				this.givenValidation = validation;
			}
		},
		created() {
			this.$on('should-validate', this.addValidation);
			this.state = new ContactState(this.value[0], this);
			this.state.baseName = this.fieldProps.baseName;
			this.state.index = 0;
		}
	};

	function setupLocalVue() {
		const localVue = createLocalVue();
		localVue.use(bedpostVueGlobals);
		localVue.use(Vuelidate);
		return localVue;
	}

	function setup(assign, fieldProps) {
		const localVue = setupLocalVue();

		let value = [Object.assign({}, global.gon.dummy, assign || {})];
		fieldProps = Object.assign({}, defaultProps, fieldProps || {});
		let parent = mount(wrapperComponent, {
			propsData: {fieldProps, value},
			localVue,
		});
		let wrapper = parent.find(EncounterContactField);
		return {wrapper, parent};
	}

	function chooseRadio(wrapper, field, value) {
		const name = `${wrapper.vm.state.baseName}[${field}]`;
		const radio = wrapper.find(`[name="${name}"][value=${value}]`);
		radio.find('input').setChecked(true);
		return radio;
	}

	it('mounts with a new record', () => {
		let {wrapper} = setup({newRecord: true});
		expect(wrapper.exists()).toBeTruthy();
	});

	it('mounts with an existing record', () => {
		let {wrapper} = setup({possible_contact_id: 'pos2'});
		expect(wrapper.exists()).toBeTruthy();
		expect(wrapper.vm.state.contact_type).toBe('penetrated');
	});

	it('has the correct subject input name', () => {
		const {wrapper} = setup();

		const fieldName = `${wrapper.vm.state.baseName}[subject]`;
		const result = wrapper.contains(`[name='${fieldName}']`);

		expect(result).toBe(true);
	});

	it('has the correct object input name', () => {
		const {wrapper} = setup();

		const fieldName = `${wrapper.vm.state.baseName}[object]`;
		const result = wrapper.contains(`[name='${fieldName}']`);
		expect(result).toBe(true);
	});

	describe('validation', () => {
		it('emits a validation configuration from its parent', () => {
			const {parent} = setup();

			expect(parent.emitted()['should-validate']).toBeTruthy();
		});
	});

	// describe('onKeyChange', () => {
	// 	it('is called when the watchKey changes', () => {
	// 		let watchKey = 0;
	// 		const onKeyChange = jest.fn();
	// 		const {wrapper} = setup({}, {watchKey});
	// 		wrapper.setMethods({onKeyChange});

	// 		wrapper.setProps({watchKey: watchKey + 1});

	// 		expect(onKeyChange).toHaveBeenCalledTimes(1);
	// 	});

	// 	it('calls updateContactType', () => {
	// 		const updateContactType = jest.fn();
	// 		const {wrapper} = setup();

	// 		wrapper.setMethods({updateContactType});
	// 		wrapper.vm.onKeyChange();
	// 		return wrapper.vm.$nextTick().then(() => {
	// 			expect(updateContactType).toHaveBeenCalledTimes(1);
	// 		});

	// 	});
	// });



	describe('cascading', () => {
		describe('with an invalid contact', () => {
			it('sets the subject_instrument_id if there is only one option', async () => {
				const {wrapper} = setup({possible_contact_id: 'pos1'});
				await chooseRadio(wrapper, 'object_instrument_id', 'hand');
				expect(wrapper.vm.state.subject_instrument_id).toEqual('tongue');
			});

			it('unsets the subject_instrument_id if there is more than one option', async () => {
				const {wrapper} = setup({possible_contact_id: 'pos3'});

				await chooseRadio(wrapper, 'object_instrument_id', 'anus');
				expect(wrapper.vm.state.subject_instrument_id).toBeFalsy();
			});
		});
	});

	describe('setContact', () => {
		it('touches fields when they are changed', () => {
			const {wrapper} = setup();
			expect(wrapper.vm.$v.$anyDirty).toBe(false);

			chooseRadio(wrapper, 'subject', 'partner');
			expect(wrapper.vm.$v.$anyDirty).toBe(true);
			expect(wrapper.vm.$v.subject.$dirty).toBe(true);
		});

		it('touches the possible contact field when it is changed through choosing instruments', () => {
			const {wrapper} = setup();
			chooseRadio(wrapper, 'object_instrument_id', 'anus');
			expect(wrapper.vm.$v.$anyDirty).toBe(false);
			chooseRadio(wrapper, 'subject_instrument_id', 'hand');
			expect(wrapper.vm.value.possible_contact_id).toBeTruthy();
			expect(wrapper.vm.$v.possible_contact_id.$dirty).toBe(true);
		});
	});

	describe('updateBarriers', () => {
		it('dirties the barriers if called with a truthy value', () => {
			const {wrapper} = setup();
			wrapper.vm.$v.$reset();

			wrapper.vm.updateBarriers('any_arg');
			expect(wrapper.vm.$v.barriers.$dirty).toBe(true);
		});

		it('does not dirty the barriers if called with false', () => {
			const {wrapper} = setup();
			wrapper.vm.updateBarriers(false);
			expect(wrapper.vm.$v.$anyDirty).toBe(false);
		});
	});
});
