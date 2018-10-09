import { required, email, minLength, maxLength, sameAs } from 'vuelidate/lib/validators'
import fieldErrors from "./fieldErrorsComponent.vue"

function formatValidators(formFields) {
	let validators = {}
	let g_vals = Object.keys(gon.validators);
	for (var i = 0; i < g_vals.length; i++) {
		let field = g_vals[i];
		if (formFields.indexOf(field) < 0) {
			continue;
		}

		validators[field] = {}
		let f_vals = gon.validators[field]
		if (field == "email") {
			validators[field].email = email
		}
		for (var f = 0; f < f_vals.length; f++) {
			let [type, opts] = f_vals[f];

			switch(type) {
				case "presence":
					validators[field].blank = required
					break;
				case "length":
					if (opts.maximum) {
						validators[field].too_long = maxLength(opts.maximum)
					}
					if (opts.minimum) {
						validators[field].too_short = minLength(opts.minimum)
					}
					break;
				case "confirmation":
					let conf_field = field + "_confirmation";
					validators[conf_field] = validators[conf_field] || {};

					validators[field].blank = required;
					validators[conf_field].confirmation = sameAs(field);
					break
			}
		}
	}
	return validators;
}

export default {
	data: function() {
		let dt = gon.form_obj;
		if (gon.form_obj.password_digest !== undefined) {
			dt.password = dt.password || "";
			dt.password_confirmation = dt.password_confirmation || "";
		}
		dt.showPass = false;
		return dt;

	},
	props: {
		validate: String
	},
	components: {
		fieldErrors
	},
	validations: function() {
		return formatValidators(this.$props.validate);
	},
	computed: {
		validationList: function() {
			return this.$props.validate.split(",");
		},
		passType: function() {
			return this.showPass ? "text" : "password";
		},
		passText: function() {
			let key = this.showPass ? "hide_password" : "show_password"
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
				for (var i = 0; i < this.validationList.length; i++) {
					let field = this.validationList[i];
					if (this.$v[field].$invalid) {
						this.$refs[field].focus()
						break;
					}
				}
			}
		},
		togglePassword() {
			this.showPass = !this.showPass
		}
	}
}
