import BaseState from '@components/form/state/BaseState';

/**
 * An object to track the state of a contact being built by EncounterContactField
 */
export default class ContactState extends BaseState {
	constructor(contact, vm, baseName, index) {
		super(contact, vm, baseName, index);
		// add all the gon data
		Object.assign(this, gon.encounter_data);

		// make internal fields for stuff that doesn't get saved on the contact
		this.contact_type = 'touched';
		this.subject_instrument_id = null;
		this.object_instrument_id = null;
		this.encounter = vm.formData;

		// if there's an existing contact, get the internal fields for it
		if (contact.possible_contact_id) {
			for (let p in this.possibles) {
				let found = this.possibles[p].find((i) => i._id == this.contact.possible_contact_id);

				if (found) {
					this.contact_type = p;
					this.subject_instrument_id = found.subject_instrument_id;
					this.object_instrument_id = found.object_instrument_id;
					break;
				}
			}
		}
	}


	/**
	 * the contact object
	 *
	 * @return {object} the contact
	 */
	get contact() { return this.item; }

	/**
	 * the contact_type object
	 *
	 * @return {object} the contact_type properties
	 */
	get cType() { return this.contacts[this.contact_type]; }

	/**
	 * is this contact a self-contact?
	 *
	 * @return {boolean} whether the subject and object of the contact are the same
	 */
	get isSelf() { return this.contact.subject == this.contact.object; }

	/**
	 * should this contact show subject instrument options?
	 *
	 * @return {boolean} whether the subject instrument options should show
	 */
	get hasSubjectInstruments() { return this.shownInstruments.subject.length > 1; }

	/**
	 * The selected partner in this encounter
	 *
	 * @return {object} data on the partner
	 */
	get partner() { return this.encounter.partnership_id && this.partners.find((p) => p._id == this.encounter.partnership_id);}

	/**
	 * The pronoun the selected partner uses
	 *
	 * @return {object} the pronoun data
	 */
	get partnerPronoun() { return this.partner && this.pronouns[this.partner.pronoun_id]; }

	/**
	 * the posessive pronoun for the subject of this contact
	 *
	 * @return {string} the possessive pronoun
	 */
	get subjPossessive() {
		if (this.shownInstruments.subject.length <= 1 || !this.partnerPronoun) {
			return '';
		}
		return this.$_t('contact.with', {pronoun: this.contact.subject == 'user' ? this.$_t('my') : this.partnerPronoun.possessive});
	}

	/**
	 * the possible contact id of this contact
	 *
	 * @return {object} the contact that matches the chosen instruments and contact type
	 */
	get possible_contact_id() {
		// get the possible contact that matches the contact_type, subject_instrument_id, and object_instrument_id
		if(this.shownInstruments.subject.every((i) => i._id != this.subject_instrument_id) ||
			this.shownInstruments.object.every((i) => i._id != this.object_instrument_id) ) {
			return undefined;
		}
		let contact = this.possibles[this.contact_type].find((i) => i.subject_instrument_id == this.subject_instrument_id && i.object_instrument_id == this.object_instrument_id);
		return contact && contact._id;
	}

	/**
	 * aria labels for each radio group in the field
	 *
	 * @return {object} aria labels keyed by field
	 */
	get radiogroupLabels() {
		const contact_type = this.$_t(this.cType.t_key, {scope: 'contact.contact_type_action'});
		let object_name, object_reflexive_name;
		if (this.contact.object == 'user') {
			object_name = this.$_t('you');
			object_reflexive_name = this.isSelf ? this.$_t('yourself') : object_name;
		} else {
			object_name = this.partner.name;
			object_reflexive_name = this.isSelf ? this.partnerPronoun.reflexive : this.partner.name;
		}

		const subject_name = this.contact.subject == 'user' ? this.$_t('you') : this.partner.name;

		const tArgs = {
			contact_type,
			object_name,
			subject_name,
			object_reflexive_name,
			scope: 'helpers.label.encounter'
		};

		return {
			contact_type: this.$_t('contact_type', tArgs),
			subject: this.$_t('subject', tArgs),
			object: this.$_t(`object.${this.contact.subject}`, tArgs),
			subject_instrument_id: this.$_t(`subject_instrument.${this.contact.subject}`, tArgs),
			object_instrument_id: this.$_t(`object_instrument.${this.contact.object}`, tArgs),
		};
	}

	/**
	 * the instruments to show as options for subject and object instrument id
	 *
	 * @return {object} a dictionary of option arrays
	 */
	get shownInstruments() {
		const current_object = this.object_instrument_id;

		let shown = {object: {}, subject: {}};
		let newObjects = [];
		let newSubjects = [];

		// get the condition keys to only show instruments the actors have
		let objConditionKeys = this.getConditionKey(false);
		let subjConditionKeys = this.getConditionKey(true);
		// for each possible contact in the contact_type
		this.possibles[this.contact_type].forEach((p) => {
			// skip it if it's not currently possible
			if (this.isSelf && !p.self_possible) {
				return;
			}

			// add it to possible object instruments if it's not already in the list and the person has it
			const pObj = this.instruments[p.object_instrument_id];
			if (!shown.object[pObj._id] && this.personHasInst(pObj, this.contact.object, objConditionKeys)) {
				newObjects.push(pObj);
				shown.object[pObj._id] = true;
			}

			// skip if this possible object instrument isn't the currently selected one
			// or this possible subject instrument is already show
			if (pObj._id != current_object || shown.subject[p.subject_instrument_id]) {
				return;
			}

			// add it to possible subject instruments if the person has it
			const pSubj = this.instruments[p.subject_instrument_id];
			if (this.personHasInst(pSubj, this.contact.subject, subjConditionKeys)) {
				newSubjects.push(pSubj);
				shown.subject[pSubj._id] = true;
			}
		});

		const sortFunc = (a,b) => (a.alias_of_id || a._id).localeCompare((b.alias_of_id || b._id));
		this._subjectInstruments = newSubjects.sort(sortFunc);
		this._objectInstruments = newObjects.sort(sortFunc);
		return {
			subject: this._subjectInstruments,
			object: this._objectInstruments
		};
	}

	/**
	 * the current state as a sentence
	 *
	 * @return {string} a sentence representation of what the user has chosen for the contact
	 */
	get asSentence() {
		let subject = this.contact.subject == 'user' ? this.$_t('I') : this.partner.name;
		let contact = this.$_t(`contact.contact_type.${this.cType.t_key}`);
		let object = this.contact.object == 'user' ? this.$_t('my') : this.partnerPronoun.possessive;
		let objInst = this.object_instrument_id ? this.instruments[this.object_instrument_id][this.contact.object + '_name'] : 'blank';
		let subjInst = this.hasSubjectInstruments ?
			(this.subject_instrument_id ? this.instruments[this.subject_instrument_id][this.contact.subject + '_name'] : 'blank') : '';

		return `contact ${this.index + 1}: ${subject} ${contact} ${object} ${objInst} ${this.subjPossessive} ${subjInst}`;
	}

	/**
	 * Get the given actor's name for the given instrument
	 *
	 * @param  {string} instrument the instrument to get a name for
	 * @param  {string} actor 'object' or 'subject'
	 * @return {string}       the proper language for the actor's instrument
	 */
	instrumentName(instrument, actor) {
		if (!instrument.user_override) { return this.$_t(instrument._id, {scope: 'contact.instrument'}); }

		let person = this[this.contact[actor]];
		return person[instrument.user_override];
	}

	/**
	 * Get the given actor's name for the chosen instrument
	 *
	 * @param  {string} actor 'object' or 'subject'
	 * @return {string}       the proper language for the actor's instrument
	 */
	chosenInstrumentName(actor) {
		let instID  = this[`${actor}_instrument_id`];
		if (!instID) {return '';}
		let instrument = this.instruments[instID];
		return this.instrumentName(instrument, actor);
	}

	/**
	 * Does the given person have the given instrument?
	 *
	 * @param  {object} instrument    the instrument
	 * @param  {object} person        the person's data
	 * @param  {string[]} conditionKeys keys to look for conditions within
	 * @return {boolean}               whether the person has the instrument and it can be shown as an option
	 */
	personHasInst(instrument, person, conditionKeys) {
		// find the first set of conditions that exists on the instrument
		let key = instrument.conditions && conditionKeys.find((k) => instrument.conditions[k] !== undefined);

		// if there isn't one, the person has the instrument
		if(!key) { return true; }
		// the person has the instrument if all conditions are true
		return instrument.conditions[key].every((c) => this[person][c]);
	}

	/**
	 * Get the keys for possible conditions on an instrument
	 *
	 * @param  {boolean} forSubject are these keys for the subject? false if they are for the object
	 * @return {string[]}            condition keys
	 */
	getConditionKey(forSubject) {
		let conditionKey = this.cType[forSubject ? 'inst_key' : 'inverse_inst'];
		let conditions = ['all', conditionKey];
		// add the self key in the middle
		if (this.isSelf) {
			conditions.splice(1, 0, conditionKey += '_self');
		}
		return conditions;
	}

	/**
	 * Set the possible contact id
	 *
	 * @return {boolean} whether the possible contact id changed
	 */
	setContact() {
		// get the old value
		const oldPossible = this.contact.possible_contact_id;
		// set the instruments properly
		this.findNewInst('object');
		this.findNewInst('subject');

		// get the possible contact id
		this.contact.possible_contact_id = this.possible_contact_id;
		return oldPossible != this.contact.possible_contact_id;
	}

	/**
	 * Get the instrument_id value for the actor after changes to the state
	 *
	 * @param  {string} actor 'subject' or 'object'
	 */
	findNewInst(actor) {
		// get possible instruments for the actor
		let insts = this.shownInstruments[actor];
		// get the current instrument
		let key = `${actor}_instrument_id`;
		let curID = this[key];

		// if there is only one possible, select it
		if (insts.length == 1) {
			this[key] = insts[0]._id;
		} else if (curID) {
			// otherwise find the current or an alias of it in the new set
			let newInst = insts.find((i) => curID == i._id || this.isAlias(curID, i));
			this[key] = newInst && newInst._id;
		}
	}

	/**
	 * Is the given id an alias of the given instrument (or vice versa)?
	 *
	 * @param  {string}  id         an instrument id
	 * @param  {object}  instrument an instrument
	 * @return {boolean}            whether they are the same instrument by different names
	 */
	isAlias(id, instrument) {
		return instrument.alias_of_id == id || this.instruments[id].alias_of_id == instrument._id;
	}
}
