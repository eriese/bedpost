import {createLocalVue, mount} from '@vue/test-utils';
import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import EncounterContactBarrier from '@components/form/encounter/EncounterContactBarrier.vue';

describe ('Encounter contact barrier component', () => {
	const baseName = 'encounter[contacts_attributes][0]';

	const WrapperComponent = {
		template: '<div><encounter-contact-barrier v-bind="barrierProps" v-model="barrierProps.contact.barriers"></encounter-contact-barrier></div>',
		components: {
			EncounterContactBarrier,
		},
		props: ['barrierProps'],
	};

	function makeWrapper(contact, barrier, has_barrier) {
		const encounterData = {
			has_barrier,
			index: contact.position,
			object_instrument_id: 'hand',
			subject_instrument_id: 'hand',
			partnerName: 'Alice',
			objectInstrumentName: 'hand',
			subjectInstrumentName: 'hand',
		};

		const localVue = createLocalVue();
		localVue.use(bedpostVueGlobals);

		const parent = mount(WrapperComponent, {
			propsData: {
				barrierProps: {
					barrier,
					contact,
					encounterData,
					baseName,
				},
			},
			localVue
		});

		return parent.find(EncounterContactBarrier);
	}
	describe('old barrier', () => {
		const oldBarrier = {
			key: 'old',
			conditions: null,
			exclude: ['fresh', 'clean_subject', 'clean_object'],
			encounter_conditions: ['has_barrier', 'index'],
		};

		it('Does not show if the contact is first', () => {
			const contact = {
				barriers: [],
				object: 'partner',
				position: 0,
				possible_contact_id: null,
				subject: 'user',
				newRecord: true,
			};

			const wrapper = makeWrapper(contact, oldBarrier, 0);

			expect(wrapper.vm.shouldShow).toBe(false);
		});

		it('does not show if there are no previous contacts with barriers', () => {
			const contact = {
				barriers: [],
				object: 'partner',
				position: 1,
				possible_contact_id: null,
				subject: 'user',
				newRecord: true,
			};

			const wrapper = makeWrapper(contact, oldBarrier, 0);

			expect(wrapper.vm.shouldShow).toBe(false);
		});

		it('shows if there is a previous contact with a barrier', () => {
			const contact = {
				barriers: [],
				object: 'partner',
				position: 1,
				possible_contact_id: null,
				subject: 'user',
				newRecord: true,
			};

			const wrapper = makeWrapper(contact, oldBarrier, 1);
			expect(wrapper.vm.shouldShow).toBe(true);
		});
	});
});
