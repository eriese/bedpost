<template>
	<div class="input" v-if="shouldShow">
		<input type="checkbox" ref="input" :value="inputValue" v-on="cListeners" :name="inputName" :id="inputId" :disabled="shouldDisable">
		<label :for="inputId">{{labelText}}</label>
	</div>
</template>

<script>
	import customInput from '@mixins/customInput';

	function checkConditions(conditions, foundVal, notFoundVal, checkFunc) {
		if (!conditions) {return notFoundVal;}

		for (var i = 0; i < conditions.length; i++) {
			if (checkFunc(conditions[i])) {
				return foundVal;
			}
		}

		return notFoundVal;
	}

	export default {
		name: 'encounter_contact_barrier_input',
		props: ['checked', 'barrier', 'objectName', 'subjectName', 'modelValue', 'contact', 'encounterData'],
		mixins: [customInput],
		model: {
			prop: 'modelValue',
			event: 'change'
		},
		computed: {
			modelName: function() {
				return "barriers][";
			},
			labelText: function() {
				return this.$root.t(this.barrier.key, {scope: "contact.barrier", object_instrument: this.objectName, subject_instrument: this.subjectName})
			},
			inputValue: function() {
				return this.barrier.key
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
				})
			},
			cleanKey: function() {
				if (this.barrier.key.indexOf("clean_") < 0) {
					return null;
				}

				return this.barrier.key.replace("clean_", "") + "_instrument_id";
			},
			canClean: function() {
				if (this.cleanKey === null) {return true;}
				let instID = this.contact[this.cleanKey];
				if (instID) {
					return this.encounterData.instruments[instID].can_clean
				}
				return true;
			},
			shouldShow: function() {
				return checkConditions(this.barrier.conditions, false, true, (c) => !this.contact[c])
					&& checkConditions(this.barrier.encounter_conditions, false, true, (c) => !this.encounterData[c])
					&& this.canClean
			},
			shouldDisable: function() {
				return checkConditions(this.barrier.exclude, true, false, (c) => this.modelValue.indexOf(c) >=0)
			}
		},
		methods: {
			toggleChecked(isChecked) {
				let newValue = [...this.modelValue]
				if (isChecked && this.valInd < 0) {
					newValue.push(this.inputValue);
				} else if (!isChecked && this.valInd >= 0) {
					newValue.splice(this.valInd, 1);
				}

				this.$emit('change', newValue);
			}
		},
		updated: function() {
			if (this.shouldShow) {
				this.$refs.input.checked = this.valInd >= 0;
			} else if (this.valInd >= 0) {
				this.toggleChecked(false);
			}
		},

	}
</script>
