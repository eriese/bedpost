import {required, email, minLength, maxLength, sameAs} from 'vuelidate/lib/validators';
import {submitted, validateWithServer, requireUnlessValid, acceptance} from '@modules/validation/validators';

/**
 * An object to process Vuelidate form validations so they can be used by Vuelidate
 */
export default class ValidationProcessor {
	/**
	 * Create a new processor
	 *
	 * @param  {object} givenValidators       validator descriptions from the server
	 * @param  {Array} path                  the search path through the root description object to find givenValidators at
	 * @param  {object} givenFields           fields and their values
	 * @param  {object} givenRefs             the vue root's $refs
	 * @param  {object} additionalValidations validations from other child components that have already been converted to vuelidate config
	 */
	constructor(givenValidators, path, givenFields, givenRefs, additionalValidations) {
		this.givenValidators = givenValidators || {};
		this.startingPath = path || [];
		this.givenFields = givenFields || {};
		this.givenRefs = givenRefs;
		this.validationConfig = Object.assign({}, additionalValidations);
	}

	/**
	 * Process the validations
	 *
	 * @return {object} a validation configuration object to be used by Vuelidate
	 */
	process() {
		this.usedValidators = {};
		// run through all the fields given as part of the value
		for (let fieldName in this.givenFields) {
			this.makeFieldValidatorConfig(fieldName);
		}

		// pick up any validators that are on fields not included in the value
		for (let fieldName in this.givenValidators) {
			if (this.usedValidators[fieldName] === undefined) {
				this.makeFieldValidatorConfig(fieldName);
			}
		}

		return this.validationConfig;
	}

	/**
	 * merge the given validator config with the existing one for the given field
	 *
	 * @param  {object} validatorsToAdd the validator config to add
	 * @param  {string} [fieldName]       the name of the field the config is for. defaults to the name of the field currently being processed
	 * @return {object}                 the current state of the field's validator config
	 */
	fieldValidatorConfig(validatorsToAdd, fieldName) {
		fieldName = fieldName || this.currentField;
		let field = this.validationConfig[fieldName] || {};
		this.validationConfig[fieldName] = Object.assign(field, validatorsToAdd);

		return field;
	}

	/**
	 * Make the validator configuration for the given field
	 *
	 * @param  {string} fieldName the name of the field for the configuration key
	 */
	makeFieldValidatorConfig(fieldName) {
		this.currentField = fieldName;
		let fieldValidators = this.givenValidators[fieldName];
		this.currentPath = this.startingPath.concat(fieldName);

		// if the validator configs is another object, run the formatter on it as a new level
		if (fieldValidators && fieldValidators.length === undefined) {
			// process this object and this path
			let field = this.givenFields[fieldName];
			let fieldProcessor = new ValidationProcessor(fieldValidators, this.currentPath, field, this.givenRefs);
			this.fieldValidatorConfig(fieldProcessor.process());
			return;
		}

		// if it's only supposed to validate fields that exist, skip the field if it doesn't
		if (this.givenRefs && this.givenRefs[fieldName] === undefined) { return; }

		// add a submission error validator
		this.fieldValidatorConfig({submitted: submitted(this.currentPath)});

		// if it's an email field, add an email validator
		if (fieldName.match(/email/i)) { this.fieldValidatorConfig({email}); }

		// if there are no specific validators, move on
		if(fieldValidators === undefined) { return; }

		// process the validator
		fieldValidators.forEach(this.convertToValidationConfig, this);

		// track that this field has been configured
		this.usedValidators[fieldName] = true;
	}

	/**
	 * Convert the server-supplied validation description to a Vuelidate validator configuration
	 *
	 * @param  {Array} validator the validator description structured [kind, options]
	 */
	convertToValidationConfig(validator) {
		// destructure the array
		let [type, options] = validator;

		// the types we currently handle
		switch(type) {
		case 'presence':
			// presence validators are called 'blank' for translation purposes
			this.fieldValidatorConfig({blank: required});
			break;
		case 'length':
			// length validators based on max and min
			if (options.maximum) {
				this.fieldValidatorConfig({too_long: maxLength(options.maximum)});
			}
			if (options.minimum) {
				this.fieldValidatorConfig({too_short: minLength(options.minimum)});
			}
			break;
		case 'confirmation':
			// a confirmation validator will look for a match on a field with '_confirmation' appended to it
			var conf_field = this.currentField + '_confirmation';

			// only add this validator if the confirmation field is also on the form
			if(this.givenFields[conf_field] !== undefined) {
				this.fieldValidatorConfig({confirmation: sameAs(this.currentField)}, conf_field);
			}

			break;
		case 'uniqueness':
			// validate it on the server
			this.fieldValidatorConfig({taken: validateWithServer(this.currentPath.join('.'), 'uniqueness')});
			break;
		case 'require_unless_valid':
			// validate that this or the other field exist
			this.fieldValidatorConfig({one_of: requireUnlessValid(options.path)});
			break;
		case 'acceptance':
			// if it's a group, validate acceptance using the actual value key
			var acceptedField = this.currentField.replace('_group', '');
			this.fieldValidatorConfig({acceptance: acceptance(acceptedField)});
			break;
		}
	}
}
