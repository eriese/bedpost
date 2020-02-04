<template>
	<div class="field-section" :aria-label="label" :id="`${field}-contact-${contactIndex}`" :aria-controls="ariaControls" role="radiogroup">
		<hidden-radio
			v-for="r in radios"
			:key="`${field}_${r[keyField]}`"
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

export default {
	name: 'encounter-contact-field-section',
	components: {
		'hidden-radio': hiddenRadio,
	},
	model: {
		event: 'change'
	},
	props: {
		contactIndex: Number,
		label: String,
		field: String,
		controls: {
			type: Array,
			default: () => []
		},
		valueList: Array,
		defaultProps: Object,
		keyField: String,
		value: String,
		valueConverter: Function
	},
	computed: {
		radios() {
			return this.valueList.map((v) => {
				v = this.valueConverter && typeof this.valueConverter == 'function' ? this.valueConverter(v) : v;

				return {
					...this.defaultProps,
					...v,
				};
			});
		},
		_value() {
			return this.value;
		},
		ariaControls() {
			return this.controls.join(`-contact-${this.contactIndex} `);
		}
	},
	methods: {
		emit(newVal) {
			this.$emit('change', newVal);
		}
	}
};
</script>
