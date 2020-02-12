import EncounterUtils from '@components/form/encounter/EncounterUtils';

const ACTORS = ['subject', 'object'];
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
	 * @param {object} partner 						data on the partner
	 * @param {object} user 							data on the user
	 */
	constructor(contacts, possibleContacts, instruments, partner, user) {
		this.contacts = contacts;
		this.instruments = instruments;
		this.partner = partner;
		this.user = user;

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
			if (c._destroy || !c.possible_contact_id || c.barriers.every((b) => b != 'fresh' && b != 'old')) { return; }

			// get the possible contact
			let possibleContact = that.possibleContacts[c.possible_contact_id];
			// track whether it is the first barrier on both instruments
			let isFirst = true;
			// set the value of each path if it is not already set
			this.checkInstrumentBarriers(c, possibleContact, (barrier, instrument, i) => {
				const person = c[ACTORS[i]];
				const path = `${person}.${instrument.alias_name}.${barrier.type}`;
				if (Object.getAtPath(that.barriers, path) === undefined) {
					// isFirst.push(barrier.type);
					// the value is the first contact position that has a fresh barrier on this instrument for this person
					Object.setAtPath(that.barriers, path, c.position);
				} else {
					isFirst = false;
				}
			});

			// if it's now first, but it used to say it reused a barrier, make it have a new barrier
			let oldIndex = c.barriers.indexOf('old');
			if (oldIndex >= 0 && isFirst) {
				c.barriers.splice(oldIndex, 1, 'fresh');
			}
		});
	}

	checkInstrumentBarriers(contact, possibleContact, callback) {
		for (var i = 0; i < ACTORS.length; i++) {
			const actor = ACTORS[i];
			const instrumentID = possibleContact[`${actor}_instrument_id`];
			const instrument = this.instruments[instrumentID];
			const instBarriers = instrument[`${actor}_barriers`];

			if (!instBarriers || instBarriers.length == 0) {
				continue;
			}

			const that = this;
			instBarriers.forEach((barrier) => {
				const person = that[contact[actor]];
				if (barrier.conditions && barrier.conditions.some((condition) => !person[condition])) {
					return;
				}

				const otherInstActor = ACTORS[i == 0 ? 1 : 0];
				const otherInstID = possibleContact[`${otherInstActor}_instrument_id`];
				const otherInstAlias = this.instruments[otherInstID].alias_name;
				if(barrier.with_insts && barrier.with_insts.indexOf(otherInstAlias) == -1) {
					return;
				}

				callback && callback(barrier, instrument, i);
			});
		}
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
		let has = false;
		this.checkInstrumentBarriers(contact, possibleContact, (barrier, instrument, i) => {
			let actor = ACTORS[i];
			let person = contact[actor];

			let instrumentBarriers = this.barriers[person][instrument.alias_name];
			if (instrumentBarriers && instrumentBarriers[barrier.type] < contact.position) {
				has = true;
			}
		});

		return has;
	}
}
