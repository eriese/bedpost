import { required, email, minLength, maxLength, sameAs } from 'vuelidate/lib/validators'

function formatValidators() {
	let validators = {}
	let g_vals = Object.keys(gon.validators);
	for (var i = 0; i < g_vals.length; i++) {
		let field = g_vals[i];
		validators[field] = {}
		let f_vals = gon.validators[field]
		for (var f = 0; f < f_vals.length; f++) {
			let [type, opts] = f_vals[f];

			switch(type) {
				case "presence":
					validators[field].required = required
					break;
				case "length":
					if (opts.maximum) {
						validators[field].maxLength = maxLength(opts.maxLength)
					}
					if (opts.minimum) {
						validators[field].minLength = minLength(opts.minimum)
					}
					break;
				case "confirmation":
					let conf_field = field + "_confirmation";
					validators[conf_field] = validators[conf_field] || {};
					validators[conf_field].sameAs = sameAs(field);
					break
			}
		}
	}
	return validators;
}

export default {
	data: function() {
		return gon.form_obj
	},
	template: "<div><slot></slot></div>",
	validations: function() {
		return formatValidators();
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
