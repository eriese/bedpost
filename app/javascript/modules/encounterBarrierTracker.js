import EncounterUtils from '@components/form/encounter/EncounterUtils';

const ACTORS = ['subject', 'object'];
/**
 * An object to track the placement of barriers on encounter contacts
 */
export default class EncounterBarrierTracker {
	/**
	 * Create a tracker
	 *
	 * @param {Array}  formData           the encounter form data object
	 * @param {object} possibleContacts   the possible contacts from the EncounterContactField
	 * @param {object} instruments        the instruments keyed by id
	 * @param {object} partners           a map of data on the all possible partners
	 * @param {object} user               data on the user
	 */
	constructor(formData, possibleContacts, instruments, partners, user) {
		this.encounter = formData;
		this.contacts = formData.contacts;
		this.instruments = instruments;
		this.partners = partners;
		this.user = user;

		// restructure the possible contacts to be more useful for the tracker
		this.possibleContacts = {};
		for (var c in possibleContacts) {
			possibleContacts[c].forEach((p) => {
				this.possibleContacts[p._id] = p;
			});
		}

		// process existing contacts
		this.update(this.contacts);
	}

	get partner() {
		return this.partners.find((p) => p._id == this.encounter.partnership_id);
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
					// the value is the first contact position that has a
					// fresh barrier of this type on this instrument for this person
					Object.setAtPath(that.barriers, path, c.position);
				} else {
					isFirst = false;
				}
			});

			// if it's now first, but it used to say it reused a barrier, make it have a new barrier
			let oldIndex = c.barriers.indexOf('old');
			if (oldIndex >= 0 && isFirst) {
				// splice so that vue knows a change was made to the array
				c.barriers.splice(oldIndex, 1, 'fresh');
			}
		});
	}

	/**
	 * Check to see which barriers are possible in the given contact circumstances and run a callback on each one
	 *
	 * @param  {object}   contact         the contact object
	 * @param  {object}   possibleContact the possible contact description
	 * @param  {Function} callback        a callback to run on each barrier that is possible for the contact
	 ** @param {object} barrier 	the barrier description object
	 ** @param {object} instrument 	the instrument this barrier is associated with
	 ** @param {number} i the index of ACTORS for the current actor
	 */
	checkInstrumentBarriers(contact, possibleContact, callback) {
		// for each actor type
		for (var i = 0; i < ACTORS.length; i++) {
			const actor = ACTORS[i];
			const instrumentID = possibleContact[`${actor}_instrument_id`];
			const instrument = this.instruments[instrumentID];
			const instBarriers = instrument[`${actor}_barriers`];

			// if the instrument has no possible barriers, continue
			if (!instBarriers || instBarriers.length == 0) {
				continue;
			}

			const that = this;
			// get the person who might be using this barrier
			const person = that[contact[actor]];
			// each possible barrier
			instBarriers.forEach((barrier) => {
				// if there are conditions, check that they all apply to the person
				if (barrier.conditions && barrier.conditions.some((condition) => !person[condition])) {
					return;
				}

				// get the other instrument in the contact
				const otherInstActor = ACTORS[i == 0 ? 1 : 0];
				const otherInstID = possibleContact[`${otherInstActor}_instrument_id`];
				// use the alias name to make sure the references are corrent
				const otherInstAlias = this.instruments[otherInstID].alias_name;
				// if the barrier can only be used with certain other instruments, see if the other isntrument is one
				if(barrier.with_insts && barrier.with_insts.indexOf(otherInstAlias) == -1) {
					return;
				}

				// run the callback
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

		// get possible barriers
		this.checkInstrumentBarriers(contact, possibleContact, (barrier, instrument, i) => {
			let actor = ACTORS[i];
			let person = contact[actor];

			// see if this barrier has already been used on this instrument
			let instrumentBarriers = this.barriers[person][instrument.alias_name];
			if (instrumentBarriers && instrumentBarriers[barrier.type] < contact.position) {
				has = true;
			}
		});

		// if any barrier has already been used on any instrument in the contact, it's considered to have a barrier
		return has;
	}
}
