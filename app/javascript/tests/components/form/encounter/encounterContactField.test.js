import {createLocalVue, mount} from '@vue/test-utils';
import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import EncounterContactField from '@components/form/encounter/EncounterContactField.vue';
import Vuelidate from 'vuelidate';
import HiddenRadio from '@components/form/encounter/HiddenRadio.vue';

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
		baseName: 'encounter[contacts_attributes][1]',
	};

	function setupLocalVue() {
		const localVue = createLocalVue();
		localVue.use(bedpostVueGlobals);
		localVue.use(Vuelidate);
		return localVue;
	}

	function setup(assign, propsData, options) {
		const localVue = setupLocalVue();

		let value = Object.assign({}, global.gon.dummy, assign || {});
		propsData = Object.assign({value}, defaultProps, propsData || {});
		options = options || {};
		return mount(EncounterContactField, {
			propsData,
			localVue,
			...options,
		});
	}

	it('mounts with a new record', () => {
		let field = setup({newRecord: true});
		expect(field.exists()).toBeTruthy();
	});

	it('mounts with an existing record', () => {
		let field = setup({possible_contact_id: 'pos2'});
		expect(field.exists()).toBeTruthy();
		expect(field.vm.contact_type).toBe('penetrated');
	});

	it('has the correct subject input name', () => {
		const wrapper = setup();

		const fieldName = `${wrapper.vm.baseName}[subject]`;
		const radios = wrapper.findAll(HiddenRadio);
		let partnerSubjectRadio;
		for (let r = 0; r < radios.length; r++) {
			let radio = radios.at(r);
			let radioInput = radio.vm.$refs.input;
			if (radioInput.name == fieldName && radioInput.value == 'partner') {
				partnerSubjectRadio = radio;
				break;
			}
		}

		expect(partnerSubjectRadio).not.toBeNull();
	});

	it('has the correct object input name', () => {
		const wrapper = setup();

		const fieldName = `${wrapper.vm.baseName}[object]`;
		const radios = wrapper.findAll(HiddenRadio);
		let partnerObjectRadio;
		for (let r = 0; r < radios.length; r++) {
			let radio = radios.at(r);
			let radioInput = radio.vm.$refs.input;
			if (radioInput.name == fieldName && radioInput.value == 'partner') {
				partnerObjectRadio = radio;
				break;
			}
		}

		expect(partnerObjectRadio).not.toBeNull();
	});

	describe('updateBarriers', () => {
		it('never emits a number lower than 0', () => {
			const wrapper = setup({}, {tracked: {
				has_barrier: undefined
			}});

			expect(wrapper.emitted().track[0]).toEqual([['has_barrier']]);

			wrapper.setProps({
				tracked: {has_barrier: 0},
				value: Object.assign({}, global.gon.dummy, {barriers: ['fresh']}),
			});

			wrapper.vm.updateBarriers([]);
			expect(wrapper.emitted().track[1]).toEqual(['has_barrier', 0]);
		});
	});

	describe('validation', () => {
		it('has internal validation', () => {
			const wrapper = setup();
			expect(wrapper.vm.$v).not.toBeUndefined();
		});

		it('emits a validation configuration from its parent', () => {
			const localVue = setupLocalVue();

			const parent = mount({
				template: '<div><encounter-contact-field v-bind="fieldProps"></encounter-contact-field></div>',
				components: {
					'encounter-contact-field': EncounterContactField
				},
				data() {
					return {
						fieldProps: {
							value: { ...global.gon.dummy },
							...defaultProps,
						}
					};
				},
			}, {
				localVue,
			});

			expect(parent.emitted()['should-validate']).toBeTruthy();
		});
	});

	describe('onKeyChange', () => {
		it('is called when the watchKey changes', () => {
			let watchKey = 0;
			const onKeyChange = jest.fn();
			const wrapper = setup({}, {watchKey}, {
				methods: {
					onKeyChange
				}
			});

			wrapper.setProps({watchKey: watchKey + 1});

			expect(onKeyChange).toHaveBeenCalledTimes(1);
		});

		it('calls changeActorOrder', () => {
			const updateContactType = jest.fn();
			const wrapper = setup({}, {}, {
				methods: {
					updateContactType,
				},
			});

			updateContactType.mockClear();
			wrapper.vm.onKeyChange();
			return wrapper.vm.$nextTick().then(() => {
				expect(updateContactType).toHaveBeenCalledTimes(1);
			});

		});
	});

	function chooseRadio(wrapper, inst_type, value) {
		const name = `${wrapper.vm.baseName}[${inst_type}_instrument_id]`;
		const radio = wrapper.findAll(HiddenRadio).filter(w => w.vm.inputName == name && w.vm.inputValue == value);
		radio.at(0).find('input').setChecked(true);
		return radio.at(0);
	}

	describe('resetInsts', () => {
		it('is called with true when a new object_instrument_id is selected', () => {
			const wrapper = setup({possible_contact_id: 'pos1'});
			const resetInsts = jest.fn();
			wrapper.setMethods({resetInsts});

			chooseRadio(wrapper, 'object', 'hand');
			expect(resetInsts).toHaveBeenCalledWith(true);
		});

		describe('with an invalid contact', () => {
			it('sets the subject_instrument_id if there is only one option', () => {
				const wrapper = setup({possible_contact_id: 'pos1'});
				chooseRadio(wrapper, 'object', 'hand');
				expect(wrapper.vm.subject_instrument_id).toEqual('tongue');
			});

			it('unsets the subject_instrument_id if there is more than one option', () => {
				const wrapper = setup({possible_contact_id: 'pos3'});

				chooseRadio(wrapper, 'object', 'anus');
				expect(wrapper.vm.subject_instrument_id).toBeFalsy();
			});
		});
	});

	describe('setContact', () => {
		it('is called when a new subject_instrument_id is selected', () => {
			const wrapper = setup({possible_contact_id: 'pos1'});
			const setContact = jest.fn();
			wrapper.setMethods({setContact});

			chooseRadio(wrapper, 'subject', 'anus');
			expect(setContact).toHaveBeenCalled();
		});
	});
});
