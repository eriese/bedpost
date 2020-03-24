/**
 * get translation defaults for a validator's error message
 *
 * @param  {string} validator the type of validator
 * @param  {string} [field]     the field being validated
 * @param  {string} [modelName] the name of the model the field belongs to
 * @return {string[]}           an array of translation keys to use as defaults
 */
function getDefaults (validator, field, modelName) {
	// start with defaults pertaining to the validator
	let defaults = [
		{scope: `mongoid.errors.messages.${validator}`},
		{scope: `errors.attributes.${validator}`},
		{scope: `errors.messages.${validator}`}
	];

	// if there's a modelName given, add model and field keys at the beginning
	if (modelName) {
		modelName = modelName.replace('[', '.').replace(']', '');
		defaults.unshift({scope: `mongoid.errors.models.${modelName}.${validator}`});
		defaults.unshift({scope: `mongoid.errors.models.${modelName}.attributes.${field}.${validator}`});
	}
	return defaults;
}

/**
 * props and methods for a field that uses validation and displays an error message
 */
export default {
	props: {
		$v: Object,
		submissionError: Array,
	},
	computed: {
		validity: function() {
			// it's valid if it doesn't have validation or is not invalid
			return !this.$v || !this.$v.$invalid;
		},
		hasSubmissionError() {
			return this.$v.submitted == false;
		},
		fieldSubmissionError() {
			// if it's got a submission error
			if (!this.hasSubmissionError) { return undefined; }

			let msg = this.submissionError;
			if (msg && typeof msg.join == 'function') {
				msg = msg.join(this.$_t('join_delimeter'));
			}
			// return the submission error messages joined by commas
			return msg;
		},
		errorMsg: function() {
			// if it's not meant to validate
			if (!this.$v ||
				// or it doesn't have errors or is untouched
				((!this.$v.$anyError || !this.$v.$dirty) &&
					// and it doesn't have a submission error
					!this.hasSubmissionError)) {
				// no message
				return '';
			}

			if (this.fieldSubmissionError) { return this.fieldSubmissionError; }

			let field = this.field;
			let vParams = this.$v.$params;
			// go through its other validations
			for (var validator in vParams) {
				// the first invalid one
				if (!this.$v[validator]) {

					if(vParams[validator].responseMessage) {
						let messages = vParams[validator].responseMessage.message;
						return messages.join ? messages.join(this.$_t('join_delimeter')) : messages;
					}
					// make translation interpolation arguments based on the validation type
					let params = {attribute: this.field};
					switch(validator) {
					case 'too_long':
						params.count = vParams[validator].max;
						break;
					case 'too_short':
						params.count = vParams[validator].min;
						break;
					case 'confirmation':
						params.attribute = vParams[validator].eq;
						break;
					}

					return this.getValidatorTranslation(validator, field, params);
				}
			}

			return '';
		},
		errorHTML() {
			if (this.errorMsg) {
				return `<div id="${this.field}-error" class="field-errors" aria-live="assertive" aria-atomic="true">
					<div class="aria-only">${this.$_t('helpers.aria.invalid')}</div>
					<div>${this.errorMsg}</div>
				</div>`;
			}
			else {
				return '';
			}
		}
	},
	methods: {
		/**
		 * Is this field currently valid? Runs validation before returning
		 *
		 * @return {boolean} the field's validity
		 */
		isValid() {
			if(this.$v) {
				this.$v.$touch();
				return !this.$v.$invalid;
			}

			return true;
		},
		getValidatorTranslation(validator, field, params) {
			// get the translation cascades
			let defaults = getDefaults(validator, field, this.modelName);
			// get the first key
			let transKey = defaults.shift().scope;
			// add the defaults to the params
			params.defaults = defaults;

			//translate it
			let trans = this.$_t(transKey, params);

			// TODO don't do this. make better translations
			if (trans.indexOf('is') == 0) {
				trans = trans.replace('is', '');
			}

			return trans;
		}
	}
};
