import EncounterBarrierTracker from '@modules/encounterBarrierTracker';

describe('Encounter Barrier Tracker class', () => {
	describe('processContacts', () => {
		it('ignores contacts that do not have a possible_contact_id', () => {
			const tracker = new EncounterBarrierTracker([{}], {});
			tracker.processContacts();
			expect(tracker.barriers.user).toEqual({});
			expect(tracker.barriers.partner).toEqual({});
		});

		it('ignores contacts that do not have a fresh barrier', () => {
			const tracker = new EncounterBarrierTracker([{
				possible_contact_id: 'pos1',
				barriers: ['clean_object', 'clean_subject', 'old']
			}], {});
			tracker.processContacts();
			expect(tracker.barriers.user).toEqual({});
			expect(tracker.barriers.partner).toEqual({});
		});

		it('processes contacts that have a fresh barrier', () => {
			const tracker = new EncounterBarrierTracker([{
				possible_contact_id: 'pos1',
				barriers: ['fresh'],
				subject: 'user',
				object: 'partner',
				position: 1
			}], {
				penetrated: [{
					_id: 'pos1',
					subject_instrument_id: 'hand',
					object_instrument_id: 'mouth'
				}]
			});
			tracker.processContacts();
			expect(tracker.barriers.user).toEqual({hand: 1});
			expect(tracker.barriers.partner).toEqual({mouth: 1});
		});

		it('records the index of the first contact to have a barrier on the given instrument', () => {
			const tracker = new EncounterBarrierTracker([{
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
			}], {
				penetrated: [{
					_id: 'pos1',
					subject_instrument_id: 'hand',
					object_instrument_id: 'mouth'
				}, {
					_id: 'pos2',
					subject_instrument_id: 'hand',
					object_instrument_id: 'anus'
				}]
			});
			tracker.processContacts();
			expect(tracker.barriers.user).toEqual({hand: 1});
			expect(tracker.barriers.partner).toEqual({mouth: 1, anus: 2});
		});
	});

	describe('has_barrier', () => {
		it('returns false if the given contact does not have a possible contact id', () => {
			const tracker = new EncounterBarrierTracker([{
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
			}], {
				penetrated: [{
					_id: 'pos1',
					subject_instrument_id: 'hand',
					object_instrument_id: 'mouth'
				}, {
					_id: 'pos2',
					subject_instrument_id: 'hand',
					object_instrument_id: 'anus'
				}]
			});

			const result = tracker.has_barrier({
				subject: 'user',
				object: 'partner'
			});

			expect(result).toBe(false);
		});

		it('returns false if the first barrier for both instruments is on the given contact', () => {
			const tracker = new EncounterBarrierTracker([{
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
			}], {
				penetrated: [{
					_id: 'pos1',
					subject_instrument_id: 'hand',
					object_instrument_id: 'mouth'
				}, {
					_id: 'pos2',
					subject_instrument_id: 'hand',
					object_instrument_id: 'anus'
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
			const tracker = new EncounterBarrierTracker([{
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
			}], {
				penetrated: [{
					_id: 'pos1',
					subject_instrument_id: 'hand',
					object_instrument_id: 'mouth'
				}, {
					_id: 'pos2',
					subject_instrument_id: 'hand',
					object_instrument_id: 'anus'
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
			const tracker = new EncounterBarrierTracker([{
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
			}], {
				penetrated: [{
					_id: 'pos1',
					subject_instrument_id: 'external_genitals',
					object_instrument_id: 'anus'
				}, {
					_id: 'pos2',
					subject_instrument_id: 'hand',
					object_instrument_id: 'anus'
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
	});
});
