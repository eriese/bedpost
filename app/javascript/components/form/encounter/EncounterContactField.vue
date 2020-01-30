<template>
<fieldset class="contact-field-container" :class="{blurred: !focused, invalid: incomplete}" :aria-invalid="incomplete" :aria-labelledby="`as-sentence-${watchKey}`" :aria-describedby="`contact-error-${watchKey}`">
	<div v-if="incomplete" class="contact-error" aria-live="polite" :id="`contact-error-${watchKey}`">{{$_t('mongoid.errors.models.contact.incomplete')}} <div class="aria-only">{{$_t('mongoid.errors.models.contact.aria_incomplete', {index: watchKey + 1})}}</div></div>
	<legend class="aria-only" aria-live="polite" :id="`as-sentence-${watchKey}`">{{asSentence}}</legend>
	<input type="hidden" :value="value._id" :name="baseName + '[_id]'" v-if="!value.newRecord">
	<input type="hidden" :value="value.position" :name="baseName + '[position]'">
	<input type="hidden" :value="value.possible_contact_id" :name="baseName + '[possible_contact_id]'">
	<div class="contact-field" role="group">
		<div class="field-section narrow" role="radiogroup" :aria-label="radiogroupLabels.subject" :id="`-contact-${watchKey}`" :aria-controls="`subject_instrument-contact-${watchKey}`">
			<hidden-radio v-for="i in [{labelKey: 'I', inputValue: 'user'}, {label: partner.name, inputValue: 'partner'}]"
				:key="'subj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.subject"
				model="subject"
				@change="updateContactType('subject')"
				type="link">
			</hidden-radio>
		</div>
		<div class="field-section narrow" role="radiogroup" :aria-label="radiogroupLabels.contact_type" :id="`contact_type-contact-${watchKey}`" :aria-controls="`object_instrument-contact-${watchKey} subject_instrument-contact-${watchKey}`">
			<hidden-radio v-for="c in contacts"
				:key="c.key" v-bind="{
					labelKey: 'contact.contact_type.' + c.t_key,
					inputValue: c.key,
					baseName}"
				v-model="contact_type"
				@change="resetInsts"
				type="link">
			</hidden-radio>
		</div>
		<div class="field-section narrow" role="radiogroup" :aria-label="radiogroupLabels.object" :id="`object-contact-${watchKey}`" :aria-controls="`object_instrument-contact-${watchKey}`">
			<hidden-radio v-for="i in [{label: partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'user'}]"
				:key="'obj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.object"
				model="object"
				@change="updateContactType('object')"
				type="link">
			</hidden-radio>
		</div>
		<div class="field-section" role="radiogroup" :aria-label="radiogroupLabels.object_instrument" :id="`object_instrument-contact-${watchKey}`" :aria-controls="`subject_instrument-contact-${watchKey}`">
			<hidden-radio v-for="oi in objectInsts"
				:key="oi._id"
				v-bind="{
					label: oi[value.object + '_name'],
					inputValue: oi._id,
					baseName
				}"
				v-model="object_instrument_id"
				@change="resetInsts(true)"
				type="link">
			</hidden-radio>
		</div>
		<div class="field-section narrow">
			<p v-html="subjPossessive"></p>
		</div>
		<div class="field-section" role="radiogroup" :aria-label="radiogroupLabels.subject_instrument" :id="`subject_instrument-contact-${watchKey}`">
			<hidden-radio v-for="si in subjectInsts" v-show="subjectInsts.length > 1"
				:key="si._id"
				v-bind="{
					label: si[value.subject + '_name'],
					inputValue: si._id,
					model: null,
					baseName
				}"
				v-model="subject_instrument_id"
				@change="setContact"
				type="link">
			</hidden-radio>
		</div>
	</div>
	<div class="contact-barriers clear-fix">
		<div>
			<barrier-input v-for="(bType, bKey) in barriers"
				:key="baseName + bKey"
				v-model="_value.barriers"
				@change="updateBarriers"
				ref="barriers"
				v-bind="{
					barrier: bType,
					contact: value,
					baseName,
					encounterData: tracked,
					contactData: {
						index: watchKey,
						instruments,
						object_instrument_id,
						subject_instrument_id,
						partnerName: partner.name,
						objectInstrumentName: objectName,
						subjectInstrumentName: subjectName,
					}
				}">
			</barrier-input>
		</div>
	</div>
</fieldset>
</template>

<script>
import dynamicFieldListItem from '@mixins/dynamicFieldListItem';
import hiddenRadio from './HiddenRadio.vue';
import encounterContactBarrier from './EncounterContactBarrier.vue';
import { minLength, requiredUnless } from 'vuelidate/lib/validators';
import EncounterBarrierTracker from '@modules/encounterBarrierTracker';

export default {
	data: function() {
		return Object.assign({}, gon.encounter_data, {
			orderInd: 0,
			objectInsts: [],
			subjectInsts: [],
			focused: true,
			contact_type: 'touched',
			subject_instrument_id: null,
			object_instrument_id: null,
		});
	},
	mixins: [dynamicFieldListItem],
	track: ['has_barrier'],
	components: {
		'hidden-radio': hiddenRadio,
		'barrier-input': encounterContactBarrier
	},
	computed: {
		cType: function() {
			return this.contacts[this.contact_type];
		},
		isSelf: function() {
			return this._value.subject == this._value.object;
		},
		objectName: function() {
			let p_inst_id = this.object_instrument_id;
			return p_inst_id ? this.instruments[p_inst_id][this.value.object + '_name'] : '';
		},
		subjectName: function() {
			let p_inst_id = this.subject_instrument_id;
			return p_inst_id ? this.instruments[p_inst_id][this.value.subject + '_name'] : '';
		},
		subjPossessive: function() {
			if (this.subjectInsts.length <= 1) {
				return '';
			}
			return this.$_t('contact.with', {pronoun: this.value.subject == 'user' ? this.$_t('my') : this.partnerPronoun.possessive});
		},
		radiogroupLabels() {
			const contact_type = this.$_t(this.cType.t_key, {scope: 'contact.contact_type_action'});
			let object_name, object_reflexive_name;
			if (this.value.object == 'user') {
				object_name = this.$_t('you');
				object_reflexive_name = this.isSelf ? this.$_t('yourself') : object_name;
			} else {
				object_name = this.partner.name;
				object_reflexive_name = this.isSelf ? this.partnerPronoun.reflexive : this.partner.name;
			}

			const subject_name = this.value.subject == 'user' ? this.$_t('you') : this.partner.name;

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
				object: this.$_t(`object.${this.value.subject}`, tArgs),
				subject_instrument: this.$_t(`subject_instrument.${this.value.subject}`, tArgs),
				object_instrument: this.$_t(`object_instrument.${this.value.subject}`, tArgs),
			};
		},
		asSentence() {
			let subject = this.value.subject == 'user' ? this.$_t('I') : this.partner.name;
			let contact = this.$_t(`contact.contact_type.${this.cType.t_key}`);
			let object = this.value.object == 'user' ? this.$_t('my') : this.partnerPronoun.possessive;
			let objInst = this.object_instrument_id ? this.instruments[this.object_instrument_id][this.value.object + '_name'] : 'blank';
			let subjInst = this.subjectInsts.length > 1 ?
				(this.subject_instrument_id ? this.instruments[this.subject_instrument_id][this.value.subject + '_name'] : 'blank') : '';

			return `contact ${this.watchKey + 1}: ${subject} ${contact} ${object} ${objInst} ${this.subjPossessive} ${subjInst}`;
		}
	},
	methods: {
		resetInsts(e) {
			let lst = e === true ? ['subject'] : ['object', 'subject'];
			lst.forEach((actorKey) => {
				let instId = actorKey + '_instrument_id';
				let lstId = actorKey + 'Insts';
				let newList = this[lstId + 'Get']();
				if (newList.length == 1) {
					this[instId] = newList[0]._id;
				}
				else if (!newList.find((i) => i._id == this[instId])) {
					this[instId] = null;
				}
				this[lstId] = newList;
			});
			this.setContact(e);
		},
		setContact(sourceEvent) {
			let contact = this.possibles[this.contact_type].find((i) => i.subject_instrument_id == this.subject_instrument_id && i.object_instrument_id == this.object_instrument_id);
			this._value.possible_contact_id = contact && contact._id;
			this.onInput();
			this.updateBarriers(true);
			if (sourceEvent) {
				this.$v.possible_contact_id.$touch();
			}
		},
		objectInstsGet() {
			return this.instsGet(false);
		},
		subjectInstsGet() {
			if (!this.object_instrument_id) {
				return [];
			}

			return this.instsGet(true);
		},
		getConditionKey(forSubj) {
			let conditionKey = this.cType[forSubj ? 'inst_key' : 'inverse_inst'];
			if (this.isSelf) conditionKey += '_self';
			return conditionKey;
		},
		instsGet(forSubj) {
			let checkKey = forSubj ? 'subject_instrument_id' : 'object_instrument_id';
			let filter = this.instsToShow(forSubj);

			let possibles = this.possibles[this.contact_type];
			let toShow = [];
			let shown = {};
			for (var i = 0; i < possibles.length; i++) {
				let pos = possibles[i];
				let instID = pos[checkKey];
				if (shown[instID] ||
					(forSubj && pos.object_instrument_id != this.object_instrument_id) ||
					(this.isSelf && !pos.self_possible)) {
					continue;
				}

				let inst = this.instruments[instID];
				if (filter(inst)) {
					toShow.push(inst);
					shown[instID] = true;
				}

			}
			return toShow;
		},
		instsToShow(forSubj) {
			let conditionKey = this.getConditionKey(forSubj);
			let checkUser = forSubj ? this._value.subject : this._value.object;
			let vm = this;
			return (inst) => {
				if (inst.conditions == null) {return true;}
				let conditions = inst.conditions.all || inst.conditions[conditionKey];
				if (conditions == undefined && vm.isSelf) {
					conditions = inst.conditions[conditionKey.replace('_self', '')];
				}
				if(conditions == undefined) {return true;}
				for (var i = 0; i < conditions.length; i++) {
					if (!vm[checkUser][conditions[i]]) {
						return false;
					}
				}
				return true;
			};
		},
		updateContactType(updated) {
			this.onInput();
			this.resetInsts();
			if (updated) {
				this.$v[updated].$touch();
			}
		},
		updateBarriers(noTouch) {
			this.onInput();
			if (noTouch !== true) {
				this.$v && this.$v.barriers.$touch();
			}
			this.$nextTick(() => {
				this.$emit('track');
			});
		},
		blur() {
			this.focused = false;
			this.$v.$touch();
		},
		focus() {
			this.focused = true;
		},
		getFirstInput() {
			return this.$el.querySelector(':checked');
		},
		onKeyChange() {
			// on next tick so everything has re-rendered
			this.$nextTick(() => {
				this.updateContactType();
			});
		},
	},
	mounted: function() {
		if (this.value.possible_contact_id) {
			for (let p in this.possibles) {
				let found = this.possibles[p].find((i) => i._id == this.value.possible_contact_id);

				if (found) {
					this.contact_type = p;
					this.subject_instrument_id = found.subject_instrument_id;
					this.object_instrument_id = found.object_instrument_id;
					break;
				}
			}
		}

		this.$parent.$emit('should-validate', 'contacts', {
			tooShort: minLength(1),
			$each: {
				subject: {blank: requiredUnless('_destroy')},
				object: {blank: requiredUnless('_destroy')},
				position: {blank: requiredUnless('_destroy')},
				possible_contact_id: {blank: requiredUnless('_destroy')},
				barriers: {}
			}
		});

		this.$emit('start-tracking', (list) => new EncounterBarrierTracker(list, this.possibles));

		this.updateContactType();
		this.updateBarriers(true);
	},
};
</script>
