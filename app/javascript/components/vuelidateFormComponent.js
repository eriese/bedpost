import { required, email, minLength, maxLength, sameAs } from 'vuelidate/lib/validators'
import fieldErrors from "./fieldErrorsComponent.vue"
import formErrors from "./formErrorsComponent.vue"

function formatValidators(formFields, validatorVals) {
	let validators = {}
	let g_vals = Object.keys(validatorVals);
	for (var i = 0; i < g_vals.length; i++) {
		let field = g_vals[i];
		let f_vals = validatorVals[field];
		if (f_vals.length === undefined) {
			validators[field] = formatValidators(formFields, f_vals);
		}
		if (formFields.indexOf(field) < 0) {
			continue;
		}

		validators[field] = {};

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
			showPass: false,
			formError: gon.formError,
			submissionError: {}
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
		formErrors
	},
	validations: function() {
		return {formData: formatValidators(this.$props.validate, gon.validators)};
	},
	computed: {
		passType: function() {
			if (this.$props.validate.indexOf("password") < 0) {
				return;
			};
			return this.showPass ? "text" : "password";
		},
		passText: function() {
			if (this.$props.validate.indexOf("password") < 0) {
				return;
			};
			let key = this.showPass ? "hide_password" : "show_password";
			return I18n.t(key);
		}
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
					if (child.vField.$invalid) {
						this.$refs[child.field].focus();
						break;
					}
				}
			}

			this.submissionError = {};
		},
		handleError(e) {
			let [respJson, status, xhr] = e.detail
			this.formError = respJson.formError;
			this.submissionError = respJson;
		},
		togglePassword() {
			this.showPass = !this.showPass;
		}
	}
}
