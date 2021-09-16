<template>
	<div class="input sti-test-input" :class="{'input--has-errors': errorMsg}">
		<fieldset aria-labelledby="tested-for-label" class="sti-test-input__sti-input">
			<input type="hidden" :name="`${state.baseName}[_id]`" v-model="value._id" v-if="!value.newRecord">
			<input type="hidden" :name="`${state.baseName}[tested_for_id]`" v-model="value.tested_for_id">
			<v-select
				:options="availableDiagnoses"
				v-model="value.tested_for_id"
				:input-id="inputId"
				:reduce="option => option.value"
				:clearable="false"
				@input="$emit('track')"
				>
				<template v-slot:search="search">
					<input class="vs__search" v-bind="{...search.attributes, 'aria-labelledby': 'tested-for-label', placeholder: chosenDiagnosis, 'aria-describedby': `${field}-error`}" v-on="search.events">
				</template>
				</v-select>
		</fieldset>
		<fieldset class="group-radios sti-test-input__result-input" role="radiogroup" aria-labelledby="result-label">
			<hidden-radio role="presentation" class="inline field" :base-name="state.baseName" v-model="value.positive" input-value="true" type="cta" label="Poz"></hidden-radio>
			<hidden-radio role="presentation" class="inline field" :base-name="state.baseName" v-model="value.positive" input-value="false" type="cta" label="Neg"></hidden-radio>
		</fieldset>
		<div class="sti-test-input__errors" v-html="errorHTML"></div>
	</div>
</template>

<script>
import validatedField from '@mixins/validatedField';
import customInput from '@mixins/customInput';
import dynamicFieldListItem from '@mixins/dynamicFieldListItem';
import HiddenRadio from '@components/form/encounter/HiddenRadio.vue';
import {submitted} from '@modules/validation/validators';

class StiInputTracker {
	constructor(formData) {
		this.update(formData.results);
	}

	update(list) {
		this.selected = list.reduce((arr, t) => {
			t.tested_for_id && !t._destroy && arr.push(t.tested_for_id);
			return arr;
		}, []);
	}
}

export default {
	name: 'sti-test-input',
	mixins: [validatedField, customInput, dynamicFieldListItem],
	components: {
		'hidden-radio': HiddenRadio
	},
	props: {
		model: {
			type: String,
			default: 'sti_test'
		},
	},
	computed: {
		availableDiagnoses() {
			let that = this;
			const dxToOption = (dx) => {
				return {
					label: that.$_t(dx._id, {scope: 'diagnosis.name_formal'}),
					value: dx._id
				};
			};

			if (!this.tracker || !this.tracker.selected) {
				return gon.diagnoses
				// .map(dxToOption);
			}

			return gon.diagnoses.reduce((res, diag) => {
				if (that.value.tested_for_id == diag._id || that.tracker.selected.indexOf(diag._id) < 0) {
					res.push(dxToOption(diag));
				}
				return res;
			}, []);
		},
		chosenDiagnosis() {
			return this.value.tested_for_id && this.$_t(this.value.tested_for_id, {scope: 'diagnosis.name_formal'});
		},
		hasSubmissionError() {
			return this.$v && !this.$v.tested_for_id.submitted;
		},
		field() {
			return this.inputId;
		},
		fieldSubmissionError() {
			const submissionError = this.state.submissionError;
			return submissionError.map((e) => this.getValidatorTranslation(e.error, 'tested_for_id', {value: e.value}));
		}
	},
	mounted() {
		this.$emit('start-tracking', (list) => new StiInputTracker(list));

		const indexFinder = (val) => val && `${val}.0` || '';

		this.$parent.$emit('should-validate', 'results', {
			$each: {
				tested_for_id: {
					submitted: submitted(indexFinder)
				},
			}
		});
	}
};
</script>
