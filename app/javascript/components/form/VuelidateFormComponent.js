import { required, email, minLength, maxLength, sameAs, helpers } from 'vuelidate/lib/validators';
import {submitted} from '@modules/validators';
import {onTransitionTriggered} from "@modules/transitions";
import renderless from "@mixins/renderless";

/**
 * A component to wrap a validated form. Uses [Vuelidate]{@link https://monterail.github.io/vuelidate/} for validation
 * @module
 * @mixes renderless
 * @vue-data {?module:components/stepper/FormStepComponent} stepper the stepper in this form, if there is one
 * @vue-data {Object} [submissionError={}] a mutatable copy of the errors returned from the last submission attempt
 * @vue-data {Object} formData a mutatable copy of the object being modified by the form
 * @vue-data {Object} toggles a mutatable copy of an object to track toggle states on the form
 * @vue-prop {String} validate an object containing information on what types of validation, if any, each field in the form needs
 * @vue-prop {Object} startToggles the starting state of toggles on the form
 * @vue-prop {Object} value the starting state of the value of the object modified by the form
 * @vue-prop {Object} error the starting state of the errors from the last submission attempt
 * @vue-computed {Object} slotScope the scope to bind to the slot
 * @vue-computed {Object} $v the vuelidate object
 * @listens form.onsubmit
 * @listens from.ajax:error
 * @listens module:components/form/ToggleComponent~toggle-event
 */
export default {
	mixins: [renderless],
	data: function() {
		return {
			stepper: null,
			// need these because vue doesn't like it when you mutate props
			submissionError: this.error,
			formData: this.value,
			toggles: this.startToggles,
		};
	},
	props: {
		validate: {
			type: Object,
			default: objectFactory
		},
		startToggles: {
			type: Object,
			default: objectFactory
		},
		value: {
			type: Object,
			default: objectFactory
		},
		error: {
			type: Object,
			default: objectFactory
		},
	},
	validations: function() {
		return {formData: formatValidators(this.validate, [], this.formData)};
	},
	computed: {
		slotScope: function() {
			return {
				validateForm: this.validateForm,
				handleError: this.handleError,
				toggle: this.toggle,
				$v: this.$v,
				toggles: this.toggles,
				submissionError: this.submissionError,
				formData: this.formData,
				addStepper: (newStepper) => {
					this.stepper = newStepper;
				}
			}
		}
	},
	methods: {
		/**
		 * Validate the form on submission
		 * @param  {Event} e the form submission event
		 */
		validateForm(e) {
			// run validation
			this.$v.$touch();
			// if there's a stepper and it's not fully complete
			if (this.stepper && !this.stepper.allReady()) {
				// stop the event
				e.preventDefault();
				e.stopPropagation();

				// find the next incomplete step
				this.stepper.findNext();
			}
			// otherwise if the form isn't valid
			else if (this.$v.$invalid) {
				// stop the even
				e.preventDefault();
				e.stopPropagation();

				// find the first errored field and focus it
				for (var i = 0; i < this.$children.length; i++) {
					let child = this.$children[i];
					if (child.isValid && !child.isValid()) {
						child.setFocus();
						break;
					}
				}
			}
			// let the form submit
			else {
				// set the animation for if the submission triggers a page visit
				onTransitionTriggered(e);
				// clear previous submission error
				this.submissionError = {};
			}
		},
		/**
		 * Handle an ajax error
		 * @param  {Event} e the error event
		 */
		handleError(e) {
			let [respJson, status, xhr] = e.detail
			// set the new submission error
			this.submissionError = respJson.errors;
			// re-run validations
			this.$v.$touch();
		},
		/**
		 * Toggle a state
		 * @param  {String} toggleField the field to toggle
		 * @param  {Boolean|String} newVal     the value to set the toggled field to
		 * @param  {?String} clear       the name of the field to clear with this toggle
		 */
		toggle(toggleField, newVal, clear) {
			// set the value
			this.toggles[toggleField] = newVal
			// set the clear field to null if there is one
			if (clear) {
				let toClear = clear === true ? toggleField : clear
				Object.setAtPath(this, `formData.${toClear}`, null);
			}
		}
	},
}

function objectFactory() {
	return {};
}

/**
 * Process the fields on the form to apply the correct validations to each. Uses recursion to process each level of nested validations
 * @param  {Object} validatorVals an object mapping arrays of validator arguments to their fields
 * @param  {String[]} path          the path to this level in recursive searching
 * @param  {Object} fields 			the fields available in the form
 * @return {Object}               the validator config for this level
 */
function formatValidators(validatorVals, path, fields) {
	// make an empty object to hold validation config
	let validators = {}
	// each field in this level
	for (let field in fields) {
		// get the validator configs for it
		let f_vals = validatorVals[field];
		// add the field to the path
		let this_path = path.concat(field);

		// if the validator configs is another object, run the formatter on it as a new level
		if (f_vals && f_vals.length === undefined) {
			// send this object and this path
			validators[field] = formatValidators(f_vals, this_path, fields[field]);
			continue;
		}

		// always add a submission error validator
		validators[field] = validators[field] || {}
		validators[field].submitted = submitted(this_path)

		// if it's an email field, add an email validator
		if (field.match(/email/i)) {
			validators[field].email = email;
		}

		// if there are no specific validators, move on
		if(f_vals === undefined) {
			continue;
		}

		// go through the configs
		for (var f = 0; f < f_vals.length; f++) {
			// destructure the array
			let [type, opts] = f_vals[f];

			// the types we currently handle
			switch(type) {
				case "presence":
					// presence validators are called 'blank' for translation purposes
					validators[field].blank = required;
					break;
				case "length":
					// length validators based on max and min
					if (opts.maximum) {
						validators[field].too_long = maxLength(opts.maximum);
					}
					if (opts.minimum) {
						validators[field].too_short = minLength(opts.minimum);
					}
					break;
				case "confirmation":
					// a confirmation validator will look for a match on a field with "_confirmation" appended to it
					let conf_field = field + "_confirmation";

					// only add this validator if the confirmation field is also on the form
					if(fields[conf_field] === undefined) {
						break;
					}

					validators[conf_field] = validators[conf_field] || {};
					validators[conf_field].confirmation = sameAs(field);
					break;
			}
		}
	}
	return validators;
}
