<template>
	<div class="input sti-test-input">
		<input type="hidden" :name="`${inputName}[tested_for]`" v-model="value.tested_for">
		<input type="hidden" :name="`${inputName}[tested_on]`" v-model="state.tested_on">
		<v-select
			:options="availableDiagnoses"
			v-model="value.tested_for"
			:input-id="inputId"
			:reduce="option => option.value"
			:clearable="false"
			:placeholder="value.tested_for"
			></v-select>
		<div class="group-radios" role="radiogroup">
			<hidden-radio role="presentation" class="inline field" :base-name="inputName" v-model="value.positive" input-value="true" type="cta" label="Poz"></hidden-radio>
			<hidden-radio role="presentation" class="inline field" :base-name="inputName" v-model="value.positive" input-value="false" type="cta" label="Neg"></hidden-radio>
		</div>
	</div>
</template>

<script>
import customInput from '@mixins/customInput';
import dynamicFieldListItem from '@mixins/dynamicFieldListItem';
import HiddenRadio from '@components/form/encounter/HiddenRadio.vue';

class StiInputTracker {
	constructor(list) {
		this.update(list);
	}

	update(list) {
		this.selected = list.reduce((arr, t) => {
			t.tested_for && arr.push(t.tested_for);
			return arr;
		}, []);
	}
}

export default {
	name: 'sti-test-input',
	mixins: [customInput, dynamicFieldListItem],
	components: {
		'hidden-radio': HiddenRadio
	},
	props: {
		model: {
			type: String,
			default: 'tested_for'
		},
	},
	computed: {
		availableDiagnoses() {
			let that = this;
			if (!this.tracker) {
				return [];
			}

			return gon.diagnoses.reduce((res, diag) => {
				if (this.value.tested_for == diag._id || that.tracker.selected.indexOf(diag._id) < 0) {
					res.push({
						label: that.$_t(diag._id, {scope: 'diagnosis.name_formal'}),
						value: diag._id
					});
				}
				return res;
			}, []);
		}
	},
	mounted() {
		this.$emit('start-tracking', (list) => new StiInputTracker(list));
	}
};
</script>
