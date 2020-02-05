<template>
	<div class="input" v-if="shouldShow">
		<input type="checkbox" ref="input" :value="barrier.key"  :name="inputName" :id="inputId" :disabled="shouldDisable" v-model="state.contact.barriers" v-on="cListeners">
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
	props: ['barrier', 'state', 'tracker'],
	mixins: [customInput],
	model: {
		event: 'change'
	},
	data() {
		let actorMatches = this.barrier.key.match(new RegExp(matcher));
		return {
			inputValue: this.barrier.key,
			actor: actorMatches ? actorMatches[0] : null,
		};
	},
	computed: {
		modelName: () => 'barrier][',
		labelText: function() {
			// get default arguments and key
			let transArgs = {scope: 'contact.barrier'},
				key = this.barrier.key;
			// if this barrier has an actor
			if (this.actor) {
				// the key has no mention of which actor
				key = key.replace(new RegExp('_' + matcher), '');
				// put the instrument and name in the arguments
				transArgs.instrument = this.state.instrumentName(this.actor);
				transArgs.name = this.personName;
				// pluralize as needed
				transArgs.count = transArgs.instrument.match(/[^s]s$/) ? 1 : 0;
			}

			return this.$_t(key, transArgs);
		},
		canClean: function() {
			if (this.actor == null) {return true;}
			let instID = this.state[this.actor + '_instrument_id'];
			if (instID) {
				return this.state.instruments[instID].can_clean;
			}
			return false;
		},
		shouldShow: function() {
			// if it's a clean type, only continue if it's a cleanable instrument
			if (this.barrier.key.includes('clean') && !this.canClean) {return false; }
			// if it has no conditions, show it if it's cleanable
			if (!this.barrier.encounter_conditions
				&& !this.barrier.contact_conditions) { return this.canClean; }

			// if it has encounter conditions but all are false, don't show
			if (this.barrier.encounter_conditions &&
				(!this.tracker ||
				this.barrier.encounter_conditions.every((c) => {
					return !this.tracker[c](this.state.contact);
				}))
			) { return false; }

			// if it has contact_conditions but some are false, don't show
			if (this.barrier.contact_conditions &&
				this.barrier.contact_conditions.some((c) => {
					return !this.state[c];
				})
			) { return false; }

			// show
			return true;
		},
		shouldDisable: function() {
			return this.barrier.exclude.some((c) => this.state.contact.barriers.indexOf(c) >=0);
		},
		personName() {
			let person = this.state.contact[this.actor];
			return person == 'user' ?
				this.$_t('my') :
				this.$_t('name_possessive', {name: this.state.partner.name});
		}
	},
};
</script>
