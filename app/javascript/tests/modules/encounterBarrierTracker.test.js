import EncounterBarrierTracker from '@modules/encounterBarrierTracker';

const defaultPossibles = {
	penetrated: [{
		_id: 'pos1',
		subject_instrument_id: 'hand',
		object_instrument_id: 'mouth'
	}, {
		_id: 'pos2',
		subject_instrument_id: 'hand',
		object_instrument_id: 'anus'
	}]
};

const defaultInstruments = {
	hand: {
		subject_barriers: [{type: 'glove'}],
		alias_name: 'hand'
	},
	mouth: {
		subject_barriers: [{type: 'dam'}],
		alias_name: 'mouth'
	},
	anus: {
		object_barriers: [{type: 'condom'}],
		alias_name: 'anus'
	},
	external_genitals: {
		alias_name: 'external_genitals'
	}
};

const defaultPartners = [{
	_id: 'partner',
	anus_name: 'anus',
	external_name: 'penis',
	can_penetrate: true,
}];

const getDefaultEncounter = function(contacts) {
	return {
		partnership_id: 'partner',
		contacts: contacts || []
	};
};

const getTracker = function(options) {
	options = options || {};
	let {contacts, encounter, partners, user, possibles, instruments} = options;
	return new EncounterBarrierTracker(
		encounter || getDefaultEncounter(contacts),
		possibles || defaultPossibles,
		instruments || defaultInstruments,
		partners || defaultPartners,
		user || {}
	);
};

describe('Encounter Barrier Tracker class', () => {
	describe('processContacts', () => {
		it('ignores contacts that do not have a possible_contact_id', () => {
			const tracker = getTracker();

			expect(tracker.barriers.user).toEqual({});
			expect(tracker.barriers.partner).toEqual({});
		});

		it('ignores contacts that do not have a fresh or old barrier', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos1',
					barriers: ['clean_object', 'clean_subject']
				}]
			});

			expect(tracker.barriers.user).toEqual({});
			expect(tracker.barriers.partner).toEqual({});
		});

		it('processes contacts that have a fresh barrier', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos1',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}]
			});

			expect(tracker.barriers.user).toEqual({hand: {glove: 1}});
			expect(tracker.barriers.partner).toEqual({});
		});

		it('records the index of the first contact to have a barrier on the given instrument', () => {
			const tracker = getTracker({
				contacts:[{
					possible_contact_id: 'pos1',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}, {
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 2
				},{
					possible_contact_id: 'pos1',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}]
			});

			expect(tracker.barriers.user).toEqual({hand: {glove: 1}});
			expect(tracker.barriers.partner).toEqual({anus: {condom: 2}});
		});

		it('changes an old barrier to a fresh barrier if an old barrier contact is moved about the first barrier use', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos1',
					barriers: ['old'],
					subject: 'user',
					object: 'partner',
					position: 1
				}, {
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 2
				}]
			});

			expect(tracker.contacts[0].barriers).toEqual(['fresh']);
		});

		it('associates a barrier with the object instrument if the instrument has object_barriers', () => {
			const tracker = getTracker({
				contacts:[{
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}],
				instruments: {
					hand: {
						alias_name: 'hand'
					},
					anus: {
						alias_name: 'anus',
						object_barriers: [{type: 'condom'}]
					}
				}
			});

			expect(tracker.barriers.partner.anus).toEqual({condom: 1});
		});

		it('does not associate a barrier with an instrument that does not pass the conditions for the person using it', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}],
				instruments: {
					hand: {
						alias_name: 'hand',
						subject_barriers: [{type: 'glove', conditions: ['can_penetrate']}]
					},
					anus: {
						alias_name: 'anus',
						object_barriers: [{type: 'condom'}]
					}
				}
			});

			expect(tracker.barriers.partner.anus).toEqual({condom: 1});
			expect(tracker.barriers.user.hand).toBeUndefined();
		});

		it('does not associate a barrier with an instrument that requires specific other instruments if none of those are present', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}],
				instruments: {
					hand: {
						alias_name: 'hand',
						subject_barriers: [{type: 'glove', with_insts: ['mouth']}]
					},
					anus: {
						alias_name: 'anus',
						object_barriers: [{type: 'condom'}]
					}
				}
			});
			expect(tracker.barriers.partner.anus).toEqual({condom: 1});
			expect(tracker.barriers.user.hand).toBeUndefined();
		});
	});


	describe('has_barrier', () => {
		it('returns false if the given contact does not have a possible contact id', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos1',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}, {
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 2
				}]
			});

			const result = tracker.has_barrier({
				subject: 'user',
				object: 'partner'
			});

			expect(result).toBe(false);
		});

		it('returns false if the first barrier for both instruments is on the given contact', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos1',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}, {
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 2
				}]
			});

			const result = tracker.has_barrier({
				possible_contact_id: 'pos1',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 1
			});

			expect(result).toBe(false);
		});

		it('returns true if the subject instrument had a fresh barrier on a previous contact', () => {
			const tracker = getTracker({
				contacts: [{
					possible_contact_id: 'pos1',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 1
				}, {
					possible_contact_id: 'pos2',
					barriers: ['fresh'],
					subject: 'user',
					object: 'partner',
					position: 2
				}]
			});

			const result = tracker.has_barrier({
				possible_contact_id: 'pos2',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 2
			});

			expect(result).toBe(true);
		});

		it('returns true if the object instrument had a fresh barrier on a previous contact', () => {
			const contacts = [{
				possible_contact_id: 'pos1',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 1
			}, {
				possible_contact_id: 'pos2',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 2
			}];

			const tracker = getTracker({
				contacts: contacts,
				possibles: {
					penetrated: [{
						_id: 'pos1',
						subject_instrument_id: 'external_genitals',
						object_instrument_id: 'anus'
					}, {
						_id: 'pos2',
						subject_instrument_id: 'hand',
						object_instrument_id: 'anus'
					}]
				}
			});

			const result = tracker.has_barrier(contacts[1]);

			expect(result).toBe(true);
		});

		it('returns false if there are prior barriers but they are not of a compatible type with the instruments in the current contact', () => {
			const contacts = [{
				possible_contact_id: 'pos1',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 1
			}, {
				possible_contact_id: 'pos2',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 2
			}];

			const tracker = getTracker({
				contacts: contacts,
				possibles: {
					penetrated: [{
						_id: 'pos1',
						subject_instrument_id: 'hand',
						object_instrument_id: 'mouth'
					}, {
						_id: 'pos2',
						subject_instrument_id: 'mouth',
						object_instrument_id: 'anus'
					}]
				}
			});

			const result = tracker.has_barrier(contacts[1]);

			expect(result).toBe(false);
		});
	});
});
