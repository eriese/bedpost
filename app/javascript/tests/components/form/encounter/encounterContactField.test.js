import {createLocalVue, mount} from "@vue/test-utils";
import bedpostVueGlobals from "@plugins/bedpostVueGlobals";
import EncounterContactField from "@components/form/encounter/EncounterContactField.vue";

describe("Encounter Contact Field Component", () => {

	global.gon = {
		encounter_data: {
			contacts: {
				touched: {
					key: "touched",
					inst_key: "can_touch",
					inverse_inst: "can_be_touched_by",
					inverse_key: "touched_by",
					t_key: "touched"
				},
				penetrated: {
					key: "penetrated",
					inst_key: "can_penetrate",
					inverse_inst: "can_be_penetrated_by",
					inverse_key: "penetrated_by",
					t_key: "penetrated"
				}
			},
			instruments: {
				anus: {
					can_clean: true,
					conditions: null,
					has_fluids: true,
					name: "anus",
					partner_name: "ass",
					user_name: "ass",
					user_override: "anus_name",
					_id: "anus"
				},
				hand: {
					can_clean: true,
					conditions: null,
					has_fluids: true,
					name: "hand",
					partner_name: "hand",
					user_name: "hand",
					user_override: null,
					_id: "hand"
				}
			},
			possibles: {
				touched: [
					{
						contact_type: {
							inst_key: "can_touch",
							inverse_inst: "can_be_touched_by",
							key: "touched",
							t_key: "touched"
						},
						object_instrument_id: "anus",
						self_possible: true,
						subject_instrument_id: "hand",
						_id: "pos1"
					}
				],
				penetrated: [
					{
						contact_type: {
							key: "penetrated",
							inst_key: "can_penetrate",
							inverse_inst: "can_be_penetrated_by",
							t_key: "penetrated"
						},
						object_instrument_id: "anus",
						self_possible: true,
						subject_instrument_id: "hand",
						_id: "pos2"
					}
				]
			},
			partnerPronoun: {
				obj_possessive: "theirs",
				object: "them",
				possessive: "their",
				reflexive: "themself",
				subject: "they",
				_id: "5bdb87db72c3e67e31d1b542"
			},
			barriers: {}
		},
		dummy: {
			barriers: [],
			position: 1,
			object: "partner",
			subject: "user"
		}
	}

	const defaultProps = {
		baseName: "encounter[contacts_attributes][1]",
		tracked: {}
	}

	function setup(assign, propsData) {
		let localVue = createLocalVue();
		localVue.use(bedpostVueGlobals);

		let val = Object.assign({}, global.gon.dummy, assign);
		propsData = Object.assign({}, defaultProps, propsData, {value: val})

		return mount(EncounterContactField, {
			propsData,
			localVue
		});
	}

	test('it mounts with a new record', () => {
		let field = setup({newRecord: true});
		expect(field.exists()).toBeTruthy();
	});

	test('it mounts with an existing record', () => {
		let field = setup({possible_contact_id: "pos2"})
		expect(field.exists()).toBeTruthy();
		expect(field.vm.contact_type).toBe("penetrated");
	});

})
