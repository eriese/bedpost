<template>
<div class="contact-field-container" :class="{blurred: !focused, invalid: incomplete}">
	<div v-if="incomplete" class="contact-error">{{$_t('mongoid.errors.models.contact.incomplete')}}</div>
	<input type="hidden" :value="value._id" :name="baseName + '[_id]'" v-if="!value.newRecord">
	<input type="hidden" :value="value.position" :name="baseName + '[position]'">
	<input type="hidden" :value="value.possible_contact_id" :name="baseName + '[possible_contact_id]'">
	<div class="contact-field">
		<div class="field-section narrow" role="radiogroup">
			<hidden-radio v-for="i in [{labelKey: 'I', inputValue: 'user'}, {label: partner.name, inputValue: 'partner'}]"
				:key="'subj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.subject"
				model="subject"
				@change="updateContactType"
				type="link">
			</hidden-radio>
		</div>
		<div class="field-section narrow" role="radiogroup">
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
		<div class="field-section narrow" role="radiogroup">
			<hidden-radio v-for="i in [{label: partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'user'}]"
				:key="'obj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.object"
				model="object"
				@change="updateContactType"
				type="link">
			</hidden-radio>
		</div>
		<div class="field-section" role="radiogroup">
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
		<div class="field-section" role="radiogroup">
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
				}"
				v-model="_value.barriers"
				@change="updateBarriers">
			</barrier-input>
		</div>
	</div>
</div>
</template>

<script>
import dynamicFieldListItem from '@mixins/dynamicFieldListItem';
import hiddenRadio from './HiddenRadio.vue';
import encounterContactBarrier from './EncounterContactBarrier.vue';
import { required, minLength } from 'vuelidate/lib/validators';
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
	validations() {
		return {
			value: {
				subject: {blank: required},
				object: {blank: required},
			},
			contact_type: {blank: required},
			subject_instrument_id: {blank: required},
			object_instrument_id: {blank: required},
		};
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
		incomplete() {
			return this.$v.$invalid && this.$v.$anyDirty;
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
			this.setContact();
		},
		setContact() {
			let contact = this.possibles[this.contact_type].find((i) => i.subject_instrument_id == this.subject_instrument_id && i.object_instrument_id == this.object_instrument_id);
			this._value.possible_contact_id = contact && contact._id;
			this.onInput();
			this.updateBarriers();
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
		updateContactType() {
			this.onInput();
			this.resetInsts();
			return;
		},
		updateBarriers() {
			this.onInput();
			this.$nextTick(() => {
				this.$emit('track');
			});
		},
		onInput() {
			this.$emit('input', this._value);
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
				subject: {blank: required},
				object: {blank: required},
				position: {blank: required},
				possible_contact_id: {
					blank: (v) => v !== null,
				},
			}
		});

		this.$emit('start-tracking', (list) => new EncounterBarrierTracker(list, this.possibles));

		this.updateContactType();
		this.updateBarriers();
	},
};
</script>
