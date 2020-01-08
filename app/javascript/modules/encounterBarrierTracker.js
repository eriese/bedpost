/**
 * An object to track the placement of barriers on encounter contacts
 */
export default class EncounterBarrierTracker {
	/**
	 * Create a tracker
	 *
	 * @param  {Array} contacts         	the list of contacts for the encounter
	 * @param  {object} possibleContacts 	the possible contacts from the EncounterContactField
	 */
	constructor(contacts, possibleContacts) {
		this.contacts = contacts;

		// restructure the possible contacts to be more useful for the tracker
		this.possibleContacts = {};
		for (var c in possibleContacts) {
			possibleContacts[c].forEach((p) => {
				this.possibleContacts[p._id] = p;
			});
		}

		// process existing contacts
		this.processContacts();
	}

	/**
	 * Process the contacts after they have been updated
	 */
	update() {
		this.processContacts();
	}

	/**
	 * Process the contacts to find barrier placement
	 */
	processContacts() {
		// make a fresh object
		this.barriers = {
			user: {},
			partner: {},
		};

		// go through the contacts
		this.contacts.forEach((c) => {
			// if it doesn't have a possible contact id yet or doesn't have a fresh barrier, skip it
			if (!c.possible_contact_id || c.barriers.every((b) => b != 'fresh')) { return; }

			// get the possible contact
			let possibleContact = this.possibleContacts[c.possible_contact_id];
			// paths to set for this contact
			let paths = [`${c.subject}.${possibleContact.subject_instrument_id}`, `${c.object}.${possibleContact.object_instrument_id}`];
			// set the value of each path if it is not already set
			paths.forEach((path) => {
				if (Object.getAtPath(this.barriers, path) === undefined) {
					// the value is the first contact position that has a fresh barrier on this instrument for this person
					Object.setAtPath(this.barriers, path, c.position);
				}
			}, this);
		}, this);
	}

	/**
	 * Could there be an old barrier for this contact?
	 *
	 * @param  {object}  contact the contact
	 * @return {boolean}         whether any instruments involved in this contact might already have a barrier
	 */
	has_barrier(contact) {
		// if there's no possible contact id, we can't get the instruments, so skip it
		if (contact.possible_contact_id === undefined) { return false; }
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
