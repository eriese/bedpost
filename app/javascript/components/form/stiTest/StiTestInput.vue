<template>
	<div class="input sti-test-input">
		<fieldset aria-labelledby="tested-for-label" class="sti-test-input__sti-input">
			<input type="hidden" :name="`${state.baseName}[tested_for_id]`" v-model="value.tested_for_id">
			<input type="hidden" :name="`${state.baseName}[tested_on]`" v-model="state.tested_on">
			<v-select
				:options="availableDiagnoses"
				v-model="value.tested_for_id"
				:input-id="inputId"
				:reduce="option => option.value"
				:clearable="false"
				>
				<template v-slot:search="search">
					<input class="vs__search" v-bind="{...search.attributes, 'aria-labelledby': 'tested-for-label', placeholder: chosenDiagnosis}" v-on="search.events">
				</template>
				</v-select>
		</fieldset>
		<fieldset class="group-radios sti-test-input__result-input" role="radiogroup" aria-labelledby="result-label">
			<hidden-radio role="presentation" class="inline field" :base-name="state.baseName" v-model="value.positive" input-value="true" type="cta" label="Poz"></hidden-radio>
			<hidden-radio role="presentation" class="inline field" :base-name="state.baseName" v-model="value.positive" input-value="false" type="cta" label="Neg"></hidden-radio>
		</fieldset>
	</div>
</template>

<script>
import customInput from '@mixins/customInput';
import dynamicFieldListItem from '@mixins/dynamicFieldListItem';
import HiddenRadio from '@components/form/encounter/HiddenRadio.vue';

class StiInputTracker {
	constructor(formData) {
		this.update(formData.tests_for);
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
			if (!this.tracker || !this.tracker.selected) {
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
		},
		chosenDiagnosis() {
			return this.value.tested_for && this.$_t(this.value.tested_for, {scope: 'diagnosis.name_formal'});
		},
	},
	mounted() {
		this.$emit('start-tracking', (list) => new StiInputTracker(list));
	}
};
</script>
