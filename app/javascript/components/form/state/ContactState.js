import BaseState from '@components/form/state/BaseState';
export default class ContactState extends BaseState {
	constructor(contact, vm) {
		super(contact, vm);
		// add all the gon data
		Object.assign(this, gon.encounter_data);

		// make internal fields for stuff that doesn't get saved on the contact
		this.contact_type = 'touched';
		this.subject_instrument_id = null;
		this.object_instrument_id = null;

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


	get contact() { return this.item; }

	get cType() { return this.contacts[this.contact_type]; }

	get isSelf() { return this.contact.subject == this.contact.object; }

	get hasSubjectInstruments() { return this.shownInstruments.subject.length > 1; }

	instrumentName(actor) {
		let instID  = this[`${actor}_instrument_id`];
		return instID ? this.instruments[instID][`${this.contact[actor]}_name`] : '';
	}

	get subjPossessive() {
		if (this.shownInstruments.subject.length <= 1) {
			return '';
		}
		return this.$_t('contact.with', {pronoun: this.contact.subject == 'user' ? this.$_t('my') : this.partnerPronoun.possessive});
	}

	get possible_contact_id() {
		let contact = this.possibles[this.contact_type].find((i) => i.subject_instrument_id == this.subject_instrument_id && i.object_instrument_id == this.object_instrument_id);
		return contact && contact._id;
	}

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

	get shownInstruments() {
		const current_object = this.object_instrument_id;

		let shown = {object: {}, subject: {}};
		let newObjects = [];
		let newSubjects = [];

		let objConditionKeys = this.getConditionKey(false);
		let subjConditionKeys = this.getConditionKey(true);
		this.possibles[this.contact_type].forEach((p) => {
			const pObj = this.instruments[p.object_instrument_id];
			if (this.isSelf && !p.self_possible) {
				return;
			}

			if (!shown.object[pObj._id] && this.personHasInst(pObj, this.contact.object, objConditionKeys)) {
				newObjects.push(pObj);
				shown.object[pObj._id] = true;
			}

			if (!current_object ||
				pObj._id != current_object ||
				shown.subject[p.subject_instrument_id]) {
				return;
			}

			const pSubj = this.instruments[p.subject_instrument_id];
			if (this.personHasInst(pSubj, this.contact.subject, subjConditionKeys)) {
				newSubjects.push(pSubj);
				shown.subject[pSubj._id] = true;
			}
		});

		return {
			subject: newSubjects.sort(),
			object: newObjects.sort()
		};
	}

	get asSentence() {
		let subject = this.contact.subject == 'user' ? this.$_t('I') : this.partner.name;
		let contact = this.$_t(`contact.contact_type.${this.cType.t_key}`);
		let object = this.contact.object == 'user' ? this.$_t('my') : this.partnerPronoun.possessive;
		let objInst = this.object_instrument_id ? this.instruments[this.object_instrument_id][this.contact.object + '_name'] : 'blank';
		let subjInst = this.hasSubjectInstruments ?
			(this.subject_instrument_id ? this.instruments[this.subject_instrument_id][this.contact.subject + '_name'] : 'blank') : '';

		return `contact ${this.index + 1}: ${subject} ${contact} ${object} ${objInst} ${this.subjPossessive} ${subjInst}`;
	}

	personHasInst(instrument, person, conditionKeys) {
		let key = instrument.conditions && conditionKeys.find((k) => instrument.conditions[k] !== undefined);

		if(!key) { return true; }
		let failed = instrument.conditions[key].find((c) => !this[person][c]);
		return !failed;
	}

	getConditionKey(forSubject) {
		let conditionKey = this.cType[forSubject ? 'inst_key' : 'inverse_inst'];
		let conditions = ['all', conditionKey];
		if (this.isSelf) {
			conditions.splice(1, 0, conditionKey += '_self');
		}
		return conditions;
	}

	setContact() {
		const oldPossible = this.contact.possible_contact_id;
		this.findNewInst('object');
		this.findNewInst('subject');
		this.contact.possible_contact_id = this.possible_contact_id;
		return oldPossible != this.contact.possible_contact_id;
	}

	findNewInst(actor) {
		let insts = this.shownInstruments[actor];
		let key = `${actor}_instrument_id`;
		let curID = this[key];

		if (insts.length == 1) {
			this[key] = insts[0]._id;
		} else if (curID) {
			let newInst = insts.find((i) => curID == i._id || this.isAlias(curID, i));
			this[key] = newInst && newInst._id;
		}
	}

	isAlias(id, instrument) {
		return instrument.alias_of_id == id || this.instruments[id].alias_of_id == instrument._id;
	}
}
