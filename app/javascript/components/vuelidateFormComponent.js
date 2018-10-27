import { required, email, minLength, maxLength, sameAs } from 'vuelidate/lib/validators'
import fieldErrors from "./fieldErrorsComponent.vue"

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

function getAuthenticityToken(el) {
	let inputs = el.getElementsByTagName("input");
	for (let i = 0; i < inputs.length; i++) {
		let input = inputs[i];
		if (input.name == "authenticity_token") {
			return input.value;
		}
	}
}

export default {
	data: function() {
		let dt = {formData: gon.form_obj};
		if (gon.form_obj.password_digest !== undefined) {
			dt.password = dt.password || "";
			dt.password_confirmation = dt.password_confirmation || "";
		}
		dt.showPass = false;
		dt.formError = gon.formError;
		return dt;

	},
	mounted: function() {
		this.formData.authenticity_token = getAuthenticityToken(this.$el);
	},
	props: {
		validate: String
	},
	components: {
		fieldErrors
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
			e.preventDefault();
			e.stopPropagation();
			this.$v.$touch();
			if (this.$v.$invalid) {
				// find the first errored field and focus it
				for (var i = 0; i < this.$children.length; i++) {
					let child = this.$children[i];
					if (child.vField.$invalid) {
						this.$refs[child.field].focus();
						break;
					}
				}
			} else {
				this.submitForm();
			}
		},
		submitForm() {
			this.$http.post(this.$refs.form.action + ".json", this.formData)
			.then((response) => {
				eval(response.body);
			},(errResponse) => {
				this.formError = errResponse.bodyText;
			})
		},
		togglePassword() {
			this.showPass = !this.showPass;
		}
	}
}
