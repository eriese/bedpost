<template>
	<div class="stepper__step">
		<div id="stepper-aria-label" class="aria-only" aria-live="polite">{{$_t("helpers.form_stepper.prog_label", {index: index + 1, numSteps}) }}</div>
		<slot :field-blur="fieldBlur"></slot>
	</div>
</template>

<script>
	import {lazyChild, lazyParent} from "@mixins/lazyCoupled";
	/**
	 * A component for a form step. Works with parent component [FormStepperComponent]{@link module:components/stepper/FormStepperComponent}
	 *
	 * @module
	 * @vue-data {Number} index=0 the index this step has in the list of steps
	 * @vue-data {Boolean[]} [completes=[]] an array containing the completeness values for each field in the step
	 * @vue-prop {Boolean} [optional=false] is this step optional to complete?
	 * @vue-prop {Number} numSteps the number of steps the parent component has as children
	 * @vue-computed {module:components/fieldErrorsComponent[]} fields the validated fields that are children of this step
	 * @listens module:components/form/FieldErrorsComponent~input-blur
	 * @mixes lazyChild
	 *
	 * @example
	 * <caption> Use a form step to wrap a form field or fields in a scoped slot. Don't forget to attach the blur event or have it called from somewhere in your component.</caption>
	 * <form-step :num-steps="stepper.numSteps">
	 * 	<div slot-scope="step">
	 * 		<input @blur="step.fieldBlur">
	 * 	</div>
	 * </form-step>
	 */
	export default {
		name: "form_step",
		mixins: [lazyChild, lazyParent],
		data: function() {
			return {
				index: 0, // the index this step has in the list of steps
				completes: [] // an array containing completeness values for each field in the step
			}
		},
		props: {
			optional: { // is the step optional? default false
				type: Boolean,
				default: false,
			},
			numSteps: Number // the number of steps in the stepper
		},
		computed: {
			fields: function() { // the validated fields inside the step
				return this.$children.filter((c) => c.$options.name == "field_errors")
			}
		},
		methods: {
			/** check whether the step is complete and focus on the first incomplete field
			* @param {Boolean} focusSomething should the first field be focused if nothing is incomplete?
			* @return true if the step is complete, false if it isn't
			*/
			checkComplete: function(focusSomething) {
				// if it's optional, it's always complete
				if (this.optional) {return true;}

				// get the first index of false in the completes array
				let falseInd = this.completes.indexOf(false)

				// if there is one
				if (falseInd > -1) {
					// focus that field and return false
					if (focusSomething !== false) {
						this.fields[falseInd].setFocus();
					}

					return false;
				}

				// focus the first field if there is one
				if (focusSomething && this.fields[0]) {
					this.fields[0].setFocus();
				}

				// return true. step is complete
				return true;
			},
			/** process the result of a field's validity being changed
			* called by a watched property on the field_errors component
			* @emits module:components/stepper/FormStepComponent~step-ready
			* @param {module:components/fieldErrorsComponent} field the field sending the event
			* @param {Boolean} valid whether the field is now valid
			*/
			fieldBlur(field, valid) {
				// only do the work if the field is not optional
				if (this.optional) {return;}

				// get the field's index
				let ind = this.fields.indexOf(field);
				// find the old validity value
				let old = this.completes[ind]

				// don't do anything if it hasn't changed
				if (old == valid) {
					return;
				}

				// set the new value in the completes array
				this.completes[ind] = valid;

				// if it's valid, send whether the whole step is now valid, otherwise the whole step is invalidated
				let sendValid = valid;
				if (valid) {
					sendValid = this.completes.indexOf(false) == -1;
				}

				// emit the validity of this step
				this.$emit("step-ready", sendValid);
			},
			onChildMounted() {
				// only do the work if it's not an optional step
				if (!this.optional) {
					// get the inital validity of each field for its completeness
					this.completes = this.fields.map((f) => f.validity);
				}
			}
		},
		mounted: function() {
			this.$parent.$emit('step-added');
		},
		destroyed() {
			this.$parent.$emit('step-removed');
		},
	};

	/**
	 * An event to update the parent component on whether or not this step is complete
	 * @event module:components/stepper/FormStepComponent~step-ready
	 * @property {Boolean} isComplete is the step complete?
	 */
</script>
