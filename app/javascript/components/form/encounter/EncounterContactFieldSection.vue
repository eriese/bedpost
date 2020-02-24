<template>
	<div class="field-section" :aria-label="state.radiogroupLabels[field]" :id="`${field}-contact-${state.index}`" :aria-controls="ariaControls" role="radiogroup">
		<hidden-radio
			v-for="r in radios"
			:key="`${field}_${r.inputValue}`"
			:checked="_value"
			:model="field"
			v-bind="r"
			type="link"
			@change="emit"
		></hidden-radio>
	</div>
</template>

<script>
import hiddenRadio from './HiddenRadio.vue';

/**
 * Functions to get the values for the section by field
 *
 * @type {object}
 */
const valueLists = {
	subject: (state) => [{labelKey: 'I', inputValue: 'user'}, {label: state.partner.name, inputValue: 'partner'}],
	contact_type: (state) => state.contacts,
	object: (state) => [{label: state.partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'user'}],
	object_instrument_id: (state) => state.shownInstruments.object,
	subject_instrument_id: (state) => state.shownInstruments.subject
};

/**
 * Fields whose values are controlled by the keyed field
 *
 * @type {object}
 */
const controls = {
	subject: ['subject_instrument_id'],
	contact_type: ['object_instrument_id', 'subject_instrument_id'],
	object: ['object_instrument_id'],
	object_instrument_id: ['subject_instrument_id'],
};

/**
 * A component to handle logic within a radio group inside of an EncounterContactField
 *
 * @module
 * @vue-prop {ContactState} state						the state of the contact this section is for
 * @vue-prop {string} field									the name of the field this section is for
 * @vue-prop {string} value									the current value of this section's v-model
 * @vue-computed {object[]} radios					the list of values to bind to the radio buttons in this section
 * @vue-computed {object} valueConverters 	functions to convert the valueList to the needed properties for being a radio button
 * @vue-prop {object[]} valueList						the values to use to make the radio values
 * @vue-computed {string} _value						the current value of the field
 * @vue-computed {string} ariaControls			the space-separated list of ids of fields this field impacts the value of
 */
export default {
	name: 'encounter-contact-field-section',
	components: {
		'hidden-radio': hiddenRadio,
	},
	model: {
		event: 'change'
	},
	props: {
		state: Object,
		field: String,
		value: String,
	},
	computed: {
		radios() {
			const lst = [];
			for (var v in this.valueList) {
				if(!this.valueList.hasOwnProperty(v)) { continue; }
				let val = this.valueList[v];
				val = this.valueConverter(val);

				lst.push({
					baseName: this.state.baseName,
					...this.defaultProps,
					...val,
				});
			}

			return lst;
		},
		valueConverter() {
			switch(this.field) {
			case 'contact_type':
				return (c) => {
					return {
						labelKey: `contact.contact_type.${c.t_key}`,
						inputValue: c.key
					};
				};
			case 'subject_instrument_id':
			case 'object_instrument_id':
				var actor = this.field.split('_')[0];
				return (i) => {
					return {
						label: i[`${this.state.contact[actor]}_name`],
						inputValue: i._id
					};
				};
			}
			return (a) => a;
		},
		valueList() {
			return valueLists[this.field](this.state);
		},
		_value() {
			return this.value;
		},
		ariaControls() {
			return controls[this.field] && controls[this.field].map((c) => `${c}-contact-${this.state.index} `).join(' ');
		}
	},
	methods: {
		emit(newVal) {
			this.$emit('change', newVal);
		}
	}
};
</script>
