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
const valueLists = {
	subject: (state) => [{labelKey: 'I', inputValue: 'user'}, {label: state.partner.name, inputValue: 'partner'}],
	contact_type: (state) => state.contacts,
	object: (state) => [{label: state.partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'user'}],
	object_instrument_id: (state) => state.shownInstruments.object,
	subject_instrument_id: (state) => state.shownInstruments.subject
};

const controls = {
	subject: ['subject_instrument_id'],
	contact_type: ['object_instrument_id', 'subject_instrument_id'],
	object: ['object_instrument_id'],
	object_instrument_id: ['subject_instrument_id'],
};

export default {
	name: 'encounter-contact-field-section',
	components: {
		'hidden-radio': hiddenRadio,
	},
	model: {
		event: 'change'
	},
	data() {
		return {
			valueConverters : {
				contact_type: (c) => {
					return {
						labelKey: `contact.contact_type.${c.t_key}`,
						inputValue: c.key
					};
				},
				subject_instrument_id: (i) => {
					return {
						label: i[`${this.state.contact.subject}_name`],
						inputValue: i._id
					};
				},
				object_instrument_id: (i) => {
					return {
						label: i[`${this.state.contact.object}_name`],
						inputValue: i._id
					};
				}
			}
		};
	},
	props: {
		state: Object,
		field: String,
		valueList: [Array, Object],
		defaultProps: Object,
		keyField: String,
		value: String,
	},
	computed: {
		radios() {
			const lst = [];
			for (var v in this._valueList) {
				if(!this._valueList.hasOwnProperty(v)) { continue; }
				let val = this._valueList[v];
				val = this.valueConverters[this.field] ? this.valueConverters[this.field](val) : val;

				lst.push({
					baseName: this.state.baseName,
					...this.defaultProps,
					...val,
				});
			}

			return lst;
		},
		_valueList() {
			return this.valueList || valueLists[this.field](this.state);
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
