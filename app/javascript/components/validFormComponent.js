import { required, email, minLength, maxLength, sameAs } from 'vuelidate/lib/validators'
import fieldErrorsComponent from "./fieldErrorsComponent.vue"

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
					validators[field].required = required
					break;
				case "length":
					if (opts.maximum) {
						validators[field].maxLength = maxLength(opts.maximum)
					}
					if (opts.minimum) {
						validators[field].minLength = minLength(opts.minimum)
					}
					break;
				case "confirmation":
					let conf_field = field + "_confirmation";
					validators[conf_field] = validators[conf_field] || {};
					validators[field].required = required;
					validators[conf_field].sameAs = sameAs(field);
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
		return dt;
	},
	props: {
		validate: String
	},
	components: {
		'field-errors': fieldErrorsComponent
	},
	validations: function() {
		return formatValidators(this.$props.validate);
	},
	methods: {
		validateForm(e) {
			this.$v.$touch();
			if (this.$v.$invalid) {
				e.preventDefault();
			}
		}
	}
}
