import {createLocalVue, mount} from '@vue/test-utils';
import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import EncounterContactBarrier from '@components/form/encounter/EncounterContactBarrier.vue';
import I18nConfig from '@modules/i18n-config';

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
		const contactData = {
			index: contact.position,
			object_instrument_id: 'hand',
			subject_instrument_id: 'hand',
			partnerName: 'Alice',
			objectInstrumentName: 'hand',
			subjectInstrumentName: 'hand',
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
					contact,
					encounterData: tracker,
					baseName,
					contactData,
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
				possible_contact_id: null,
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
				possible_contact_id: null,
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

				const wrapper = makeWrapper(contact, cleanSubject, false);
				const subjectInstrumentName = 'random';
				wrapper.setProps({
					contactData: Object.assign({},wrapper.vm.contactData, {subjectInstrumentName})
				});

				expect(wrapper.text()).toContain(subjectInstrumentName);
			});

			it('includes the name of the partner if the subject is partner', async () => {
				await I18nConfig.setup();
				const wrapper = makeWrapper(contact, cleanSubject, false);
				expect(wrapper.text()).toContain(wrapper.vm.contactData.partnerName);
			});

			it('pluralizes if the name of the instrument ends in an s', async() => {
				await I18nConfig.setup();

				const wrapper = makeWrapper(contact, cleanSubject, false);
				const subjectInstrumentName = 'hands';
				wrapper.setProps({
					contactData: Object.assign({},wrapper.vm.contactData, {subjectInstrumentName})
				});

				const namePossessive = wrapper.vm.personName;
				const expected = I18nConfig.t('contact.barrier.clean', {count: 1, instrument: subjectInstrumentName, name: namePossessive});
				expect(wrapper.text()).toEqual(expected);
			});

			it('does not pluralize if the name of the instrument ends in ss (e.g. ass)', async () => {
				await I18nConfig.setup();

				const wrapper = makeWrapper(contact, cleanSubject, false);
				const subjectInstrumentName = 'ass';
				wrapper.setProps({
					contactData: Object.assign({},wrapper.vm.contactData, {subjectInstrumentName})
				});

				const namePossessive = wrapper.vm.personName;
				const expected = I18nConfig.t('contact.barrier.clean', {count: 0, instrument: subjectInstrumentName, name: namePossessive});
				expect(wrapper.text()).toEqual(expected);
			});

			it('does not pluralize if the name of the instrument is singular', async () => {
				await I18nConfig.setup();

				const wrapper = makeWrapper(contact, cleanSubject, false);
				const subjectInstrumentName = 'hand';
				wrapper.setProps({
					contactData: Object.assign({},wrapper.vm.contactData, {subjectInstrumentName})
				});

				const namePossessive = wrapper.vm.personName;
				const expected = I18nConfig.t('contact.barrier.clean', {count: 0, instrument: subjectInstrumentName, name: namePossessive});
				expect(wrapper.text()).toEqual(expected);
			});
		});
	});

	describe('toggleChecked', () => {
		const newBarrier = {
			key: 'fresh',
			conditions: null,
			exclude: ['old', 'clean_subject', 'clean_object'],
		};

		describe('when it is in the list', () => {
			const contact = {
				barriers: ['fresh'],
				object: 'partner',
				position: 0,
				possible_contact_id: null,
				subject: 'partner',
				newRecord: true,
			};

			it('removes itself from the list if it is being unchecked', () => {
				const wrapper = makeWrapper(contact, newBarrier, true);
				wrapper.vm.toggleChecked(false);
				expect(wrapper.emitted('change')[0][0]).not.toContain(newBarrier.key);
			});

			it('does not remove itself from the list if it is being checked', () => {
				const wrapper = makeWrapper(contact, newBarrier, true);
				wrapper.vm.toggleChecked(true);
				expect(wrapper.emitted('change')[0][0]).toContain(newBarrier.key);
			});
		});

		describe('when it is not in the list', () => {
			const contact = {
				barriers: [],
				object: 'partner',
				position: 0,
				possible_contact_id: null,
				subject: 'partner',
				newRecord: true,
			};

			it('adds itself to the list if it is being checked', () => {
				const wrapper = makeWrapper(contact, newBarrier, true);
				wrapper.vm.toggleChecked(true);
				expect(wrapper.emitted('change')[0][0]).toContain(newBarrier.key);
			});

			it('does not add itself to the list if it is being unchecked', () => {
				const wrapper = makeWrapper(contact, newBarrier, true);
				wrapper.vm.toggleChecked(false);
				expect(wrapper.emitted('change')[0][0]).not.toContain(newBarrier.key);
			});
		});
	});
});
