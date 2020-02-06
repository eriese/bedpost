import EncounterUtils from '@components/form/encounter/EncounterUtils';
/**
 * An object to track the placement of barriers on encounter contacts
 */
export default class EncounterBarrierTracker {
	/**
	 * Create a tracker
	 *
	 * @param  {Array} contacts         	the list of contacts for the encounter
	 * @param  {object} possibleContacts 	the possible contacts from the EncounterContactField
	 * @param {object} instruments				the instruments keyed by id
	 */
	constructor(contacts, possibleContacts, instruments) {
		this.contacts = contacts;
		this.instruments = instruments;

		// restructure the possible contacts to be more useful for the tracker
		this.possibleContacts = {};
		for (var c in possibleContacts) {
			possibleContacts[c].forEach((p) => {
				this.possibleContacts[p._id] = p;
			});
		}

		// process existing contacts
		this.update(contacts);
	}

	/**
	 * Process the contacts after they have been updated
	 *
	 * @param {object[]} contacts the current contact list
	 */
	update(contacts) {
		this.contacts = contacts;
		this.processContacts(contacts);
	}

	/**
	 * Process the contacts to find barrier placement
	 */
	processContacts() {
		let that = this;
		// make a fresh object
		that.barriers = {
			user: {},
			partner: {},
		};

		// go through the contacts
		that.contacts.forEach((c) => {
			// if it doesn't have a possible contact id yet or doesn't have a new or old barrier, skip it
			if (!c.possible_contact_id || c.barriers.every((b) => b != 'fresh' && b != 'old')) { return; }

			// get the possible contact
			let possibleContact = that.possibleContacts[c.possible_contact_id];
			// paths to set for this contact
			let paths = [`${c.subject}.${possibleContact.subject_instrument_id}`, `${c.object}.${possibleContact.object_instrument_id}`];
			// track whether it is the first barrier on both instruments
			let isFirst = [false, false];
			// set the value of each path if it is not already set
			paths.forEach((path, i) => {

				if (Object.getAtPath(that.barriers, path) === undefined) {
					isFirst[i] = true;
					// the value is the first contact position that has a fresh barrier on this instrument for this person
					Object.setAtPath(that.barriers, path, c.position);
				}
			});

			// if it's now first, but it used to say it reused a barrier, make it have a new barrier
			let oldIndex = c.barriers.indexOf('old');
			if (oldIndex >= 0 && isFirst[0] && isFirst[1]) {
				c.barriers[oldIndex] = 'fresh';
			}
		});
	}



	/**
	 * Could there be an old barrier for this contact?
	 *
	 * @param  {object}  contact the contact
	 * @return {boolean}         whether any instruments involved in this contact might already have a barrier
	 */
	has_barrier(contact) {
		// if there's no possible contact id, we can't get the instruments, so skip it
		if (!contact.possible_contact_id) { return false; }
		// get the possible contact
		let possibleContact = this.possibleContacts[contact.possible_contact_id];
		// get the positions of the barriers
		let subjBarrierIndex = this.barriers[contact.subject][possibleContact.subject_instrument_id];
		let objBarrierIndex = this.barriers[contact.object][possibleContact.object_instrument_id];

		// return true if either index is less that this contact's position
		return (subjBarrierIndex !== undefined && subjBarrierIndex < contact.position) ||
			(objBarrierIndex !== undefined && objBarrierIndex < contact.position);
	}
}
