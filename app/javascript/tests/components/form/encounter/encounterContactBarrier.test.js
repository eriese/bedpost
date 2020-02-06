import {createLocalVue, mount} from '@vue/test-utils';
import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import EncounterContactBarrier from '@components/form/encounter/EncounterContactBarrier.vue';
import I18nConfig from '@modules/i18n-config';

describe ('Encounter contact barrier component', () => {
	const baseName = 'encounter[contacts_attributes][0]';

	const WrapperComponent = {
		template: '<div><encounter-contact-barrier v-bind="barrierProps" v-model="barrierProps.state.contact.barriers"></encounter-contact-barrier></div>',
		components: {
			EncounterContactBarrier,
		},
		props: ['barrierProps'],
	};

	function makeWrapper(contact, barrier, has_barrier, instrumentName) {
		instrumentName = instrumentName || 'hand';

		const state = {
			contact,
			index: contact.position,
			object_instrument_id: instrumentName,
			subject_instrument_id: instrumentName,
			partner: {
				name: 'Alice',
			},
			instrumentName: () => instrumentName,
			instruments: {
				[instrumentName]: {
					can_clean: true,
				},
			},
		};

		const tracker = {
			has_barrier: () => has_barrier
		};

		const localVue = createLocalVue();
		localVue.use(bedpostVueGlobals);

		const parent = mount(WrapperComponent, {
			propsData: {
				barrierProps: {
					barrier,
					baseName,
					state,
					tracker,
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
			encounter_conditions: ['has_barrier'],
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

			const wrapper = makeWrapper(contact, oldBarrier, false);

			expect(wrapper.vm.shouldShow).toBe(false);
		});

		it('does not show if there are no previous contacts with barriers', () => {
			const contact = {
				barriers: [],
				object: 'partner',
				position: 1,
				possible_contact_id: 'pos',
				subject: 'user',
				newRecord: true,
			};

			const wrapper = makeWrapper(contact, oldBarrier, false);

			expect(wrapper.vm.shouldShow).toBe(false);
		});

		it('shows if there is a previous contact with a barrier', () => {
			const contact = {
				barriers: [],
				object: 'partner',
				position: 1,
				possible_contact_id: 'pos',
				subject: 'user',
				newRecord: true,
			};

			const wrapper = makeWrapper(contact, oldBarrier, true);
			expect(wrapper.vm.shouldShow).toBe(true);
		});
	});

	describe('labelText', () => {
		describe('clean_subject', () => {
			const cleanSubject = {
				conditions: null,
				contact_conditions: ['subject_instrument_id'],
				exclude: ['old', 'fresh'],
				key: 'clean_subject'
			};

			const contact = {
				barriers: [],
				object: 'partner',
				position: 0,
				possible_contact_id: null,
				subject: 'partner',
				newRecord: true,
			};

			it('includes the name the subject uses for the instrument', async () => {
				await I18nConfig.setup();

				const subjectInstrumentName = 'random';
				const wrapper = makeWrapper(contact, cleanSubject, false, subjectInstrumentName);

				expect(wrapper.text()).toContain(subjectInstrumentName);
			});

			it('includes the name of the partner if the subject is partner', async () => {
				await I18nConfig.setup();
				const wrapper = makeWrapper(contact, cleanSubject, false);
				expect(wrapper.text()).toContain(wrapper.vm.state.partner.name);
			});

			it('pluralizes if the name of the instrument ends in an s', async() => {
				await I18nConfig.setup();

				const subjectInstrumentName = 'hands';
				const wrapper = makeWrapper(contact, cleanSubject, false, subjectInstrumentName);

				const namePossessive = wrapper.vm.personName;
				const expected = I18nConfig.t('contact.barrier.clean', {count: 1, instrument: subjectInstrumentName, name: namePossessive});
				expect(wrapper.text()).toEqual(expected);
			});

			it('does not pluralize if the name of the instrument ends in ss (e.g. ass)', async () => {
				await I18nConfig.setup();

				const subjectInstrumentName = 'ass';
				const wrapper = makeWrapper(contact, cleanSubject, false, subjectInstrumentName);

				const namePossessive = wrapper.vm.personName;
				const expected = I18nConfig.t('contact.barrier.clean', {count: 0, instrument: subjectInstrumentName, name: namePossessive});
				expect(wrapper.text()).toEqual(expected);
			});

			it('does not pluralize if the name of the instrument is singular', async () => {
				await I18nConfig.setup();

				const subjectInstrumentName = 'hand';
				const wrapper = makeWrapper(contact, cleanSubject, false, subjectInstrumentName);

				const namePossessive = wrapper.vm.personName;
				const expected = I18nConfig.t('contact.barrier.clean', {count: 0, instrument: subjectInstrumentName, name: namePossessive});
				expect(wrapper.text()).toEqual(expected);
			});
		});
	});
});
