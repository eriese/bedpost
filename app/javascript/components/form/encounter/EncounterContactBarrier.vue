<template>
	<div class="input" v-if="shouldShow">
		<input type="checkbox" ref="input" :value="inputValue" v-on="cListeners" :name="inputName" :id="inputId" :disabled="shouldDisable">
		<label :for="inputId">{{labelText}}</label>
	</div>
</template>

<script>
import customInput from '@mixins/customInput';

const matcher = '(su|o)bject';

/**
 * a custom input for barriers in an encounter
 *
 * @vue-prop {object} barrier													the barrier that is this input's value
 * @vue-prop {Array} modelValue												the barriers list that this input adds its value to
 * @vue-prop {object} contact													the contact this input supplies barriers for
 * @vue-prop {EncounterBarrierTracker} encounterData	the tracker to check encounter_conditions against
 * @vue-prop {object} contactData											additional data about the contact
 * @vue-computed {string} modelName										the string to add to the baseName to get the inputName for this input
 * @vue-computed {string} labelText 									the text for the label
 * @vue-computed {string} inputValue									the value of this checkbox
 * @vue-computed {number} valInd 											the index of this checkbox's value in the modelValue
 * @vue-computed {object} cListeners 									the listeners to apply to the input
 * @vue-computed {string} actor												who (subject or object) this instrument belongs to if this is a clean_instrument barrier
 * @vue-computed {boolean} canClean										can the instrument referred to by this barrier be cleaned? returns true if this is not a clean_instrument barrier
 * @vue-computed {boolean} shouldShow									should this checkbox show?
 * @vue-computed {boolean} shouldDisable							should this checkbox be disabled?
 * @mixes customInput
 *
 */
export default {
	name: 'encounter_contact_barrier_input',
	props: ['barrier', 'modelValue', 'contact', 'encounterData', 'contactData'],
	mixins: [customInput],
	model: {
		prop: 'modelValue',
		event: 'change'
	},
	computed: {
		modelName: function() {
			return 'barriers][';
		},
		labelText: function() {
			// get default arguments and key
			let transArgs = {scope: 'contact.barrier'},
				key = this.barrier.key;
			// if this barrier has an actor
			if (this.actor) {
				// the key has no mention of which actor
				key = key.replace(new RegExp('_' + matcher), '');
				// put the instrument and name in the arguments
				transArgs.instrument = this.contactData[`${this.actor}InstrumentName`];
				transArgs.name = this.personName;
				// pluralize as needed
				transArgs.count = transArgs.instrument.match(/[^s]s$/) ? 1 : 0;
			}
			return this.$_t(key, transArgs);
		},
		inputValue: function() {
			return this.barrier.key;
		},
		valInd: function() {
			return this.modelValue.indexOf(this.inputValue);
		},
		cListeners: function() {
			let vm = this;
			return Object.assign({}, this.$listeners, {
				change: function(e) {
					vm.toggleChecked(e.target.checked);
				}
			});
		},
		actor: function() {
			let matches = this.barrier.key.match(new RegExp(matcher));
			return matches ? matches[0] : null;
		},
		canClean: function() {
			if (this.actor == null) {return true;}
			let instID = this.contactData[this.actor + '_instrument_id'];
			if (instID) {
				return this.contactData.instruments[instID].can_clean;
			}
			return false;
		},
		shouldShow: function() {
			// if it has no conditions, show it if it's cleanable
			if (!this.barrier.encounter_conditions && !this.barrier.contact_conditions) { return this.canClean; }

			// if it has encounter conditions but all are false, don't show
			if (this.barrier.encounter_conditions && this.encounterData && this.barrier.encounter_conditions.every((c) => !this.encounterData[c](this.contact))) { return false; }

			// if it has contact_conditions but some are false, don't show
			if (this.barrier.contact_conditions && this.barrier.contact_conditions.some((c) => !this.contactData[c])) { return false; }

			// show
			return true;
		},
		shouldDisable: function() {
			return this.barrier.exclude.some((c) => this.modelValue.indexOf(c) >=0);
		},
		personName() {
			let person = this.contact[this.actor];
			return person == 'user' ?
				this.$_t('my') :
				this.$_t('name_possessive', {name: this.contactData.partnerName});
		}
	},
	methods: {
		toggleChecked(isChecked) {
			let newValue = [...this.modelValue];
			if (isChecked && this.valInd < 0) {
				newValue.push(this.inputValue);
			} else if (!isChecked && this.valInd >= 0) {
				newValue.splice(this.valInd, 1);
			}

			this.$emit('change', newValue);
		},
	},
	updated: function() {
		if (this.shouldShow) {
			this.$refs.input.checked = this.valInd >= 0;
		} else if (this.valInd >= 0) {
			this.toggleChecked(false);
		}
	},
};
</script>
