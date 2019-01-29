import { required, email, minLength, maxLength, sameAs, helpers } from 'vuelidate/lib/validators'
import fieldErrors from "./fieldErrorsComponent.vue"
import formErrors from "./formErrorsComponent.vue"
import toggle from "./toggleComponent.vue"
import slider from "vue-slider-component"
import {onTransitionTriggered} from "../modules/transitions"

const submitted = (path) => {
	let erroredVal = undefined;
	let prevError = undefined
	return helpers.withParams({type: "submissionError", path: path}, function (value) {
		let fieldError = undefined;
		for (let p = 0; p < path.length; p++) {
			fieldError = this.submissionError[path[p]] || this.submissionError;
		}

		if (fieldError == this.submissionError) {
			return true;
		}

		if (erroredVal === undefined || prevError != this.submissionError) {
			erroredVal = value;
		}

		prevError = this.submissionError;

		return value != erroredVal;
	})
}

function formatValidators(formFields, validatorVals, path) {
	let validators = {}
	let g_vals = Object.keys(validatorVals);
	for (var i = 0; i < g_vals.length; i++) {
		let field = g_vals[i];
		let f_vals = validatorVals[field];
		let this_path = path.concat(field);
		if (f_vals.length === undefined) {
			validators[field] = formatValidators(formFields, f_vals, this_path);
		}
		if (formFields.indexOf(field) < 0) {
			continue;
		}

		validators[field] = {
			submitted: submitted(this_path)
		};

		if (field == "email") {
			validators[field].email = email;
		}
		for (var f = 0; f < f_vals.length; f++) {
			let [type, opts] = f_vals[f];

			switch(type) {
				case "presence":
					validators[field].blank = required;
					break;
				case "length":
					if (opts.maximum) {
						validators[field].too_long = maxLength(opts.maximum);
					}
					if (opts.minimum) {
						validators[field].too_short = minLength(opts.minimum);
					}
					break;
				case "confirmation":
					let conf_field = field + "_confirmation";
					validators[conf_field] = validators[conf_field] || {};

					validators[field].blank = required;
					validators[conf_field].confirmation = sameAs(field);
					break;
			}
		}
	}
	return validators;
}

export default {
	data: function() {
		let dt = {
			formData: gon.form_obj,
			toggles: gon.form_toggles || {},
			submissionError: gon.submissionError || {}
		};
		if (gon.form_obj.password_digest !== undefined) {
			dt.password = dt.password || "";
			dt.password_confirmation = dt.password_confirmation || "";
		}
		return dt;

	},
	props: {
		validate: String
	},
	components: {
		fieldErrors,
		formErrors,
		toggle,
		slider
	},
	validations: function() {
		return {formData: formatValidators(this.$props.validate, gon.validators, [])};
	},
	methods: {
		validateForm(e) {
			this.$v.$touch();
			if (this.$v.$invalid) {
				e.preventDefault();
				e.stopPropagation();
				// find the first errored field and focus it
				for (var i = 0; i < this.$children.length; i++) {
					let child = this.$children[i];
					if (child.vField !== undefined && child.vField.$invalid) {
						this.$refs[child.field].focus();
						break;
					}
				}
			} else {
				onTransitionTriggered(e);
				this.submissionError = {};
			}
		},
		handleError(e) {
			let [respJson, status, xhr] = e.detail
			this.submissionError = respJson;
			this.$v.$touch();
		},
		toggle(toggleField, new_val, clear) {
			this.toggles[toggleField] = new_val
			if (clear) {
				Object.setAtPath(this, clear, null)
			}
		}
	}
}
