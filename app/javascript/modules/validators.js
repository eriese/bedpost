import {helpers,required, email, minLength, maxLength, sameAs} from 'vuelidate/lib/validators';
import axios from 'axios';
/**
 * Custom [Vuelidate]{@link https://monterail.github.io/vuelidate/} validators
 *
 * @module validators
 */

/**
 * Make a validator that checks whether the field has a submission error
 *
 * @param  {string[]} path the path to the field in the object
 * @return {boolean}      whether there is a submission error at this path and the current value matches the errored value
 */
export const submitted = (path) => {
	// hold onto the value that caused the error
	let erroredVal = undefined;
	// hold onto the previous error
	let prevError = undefined;

	// make the validator
	return helpers.withParams({type: 'submissionError', path: path}, function (value) {
		let fieldError = undefined;

		// look for the field in the submission error
		fieldError = this.submissionError[path[path.length - 1]];

		// if there isn't one, it's valid
		if (!fieldError) {
			return true;
		}

		// set a new erroredVal if there wasn't one or this is a new error
		if (erroredVal === undefined || prevError != this.submissionError) {
			erroredVal = value;
		}

		// save this error for next time
		prevError = this.submissionError;

		// there's an error if the value is the same as the one that caused the error
		return value != erroredVal;
	});
};

/** A cache for the last found valid values of asynchronous validators */
let lastValidVals = {};

/**
 * Reset the validator cache
 */
export const resetValidatorCache = () => {
	lastValidVals = {};
};

/**
 * make a validator that makes a get request to the given url to check the validity of the given parameter path
 *
 * @param  {string|string[]} path the path inside the form object to the parameter to check
 * @param  {string} url  the url to make the get request to
 * @return {Function}      a validation function for use by Vuelidate
 */
export const validateWithServer = (path, url) => {
	let responseMessage = {}, params = {}, debounce;

	/**
	 * Delay the request by 1 minute
	 *
	 * @param  {Function} resolve the resolve function from the promise that is setting up the debouncing
	 * @param  {string} value   the value of the input being validated
	 */
	const setDebounce = (resolve, value) => {
		debounce = setTimeout(async () => {
			await validate(resolve, value);
		}, 1000);
	};

	const getCacheKey = () => `validateWithServer-${path}-${url}`;

	/**
	 * Send the request to validate the value
	 *
	 * @param  {Function} resolve the resolve function of the promise making this request
	 * @param  {string} value   the value being validated
	 * @return {Promise}         the axios request promise
	 */
	const validate = (resolve, value)=> {
		// set the value in the params
		Object.setAtPath(params, path, value);

		// make the get request
		return axios.get(url, {params}).then((response) => {
			// the response is true if the field is valid
			if (response.data === true) {
				lastValidVals[getCacheKey()] = value;
				resolve(true);
			}

			// set the message based on the response data
			responseMessage.message = Object.getAtPath(response.data, path);
			// the field is invalid
			resolve(responseMessage.message === undefined);
		}).catch(() => { resolve(false); });	// any errors count as invalid
	};

	// make the validator
	return helpers.withParams({
		type: 'serverValidated',
		url: url,
		requestParams: params,
		responseMessage
	}, function (value) {
		// debounce
		if (debounce) {
			clearTimeout(debounce);
			debounce = null;
		}

		// clear the response message
		responseMessage.message = '';

		// return true if the value is blank (allow this case to be handled by a different validator)
		if (value == '' || value === null || value == lastValidVals[getCacheKey()]) return true;

		// return a promise that resolves when the request completes
		return new Promise((resolve) => {
			setDebounce(resolve, value);
		});
	});
};

export const requireUnlessValid = (locator) => {
	return helpers.withParams({
		locator
	}, function (value) {
		const otherVal =  Object.getAtPath(this.formData, locator);
		return value || otherVal || false;
	});
};

export const acceptance = (field) => {
	return helpers.withParams({field}, (value, parentVm) => helpers.ref(field, this, parentVm) == 'true');
};

/**
 * Process the fields on the form to apply the correct validations to each. Uses recursion to process each level of nested validations
 *
 * @param  {object} validatorVals an object mapping arrays of validator arguments to their fields
 * @param  {string[]} path        the path to this level in recursive searching
 * @param  {object} fields 				the fields available in the form
 * @param {object} $refs 					the $refs from the root, which will have pointers to all inputs present on the page
 * @param {object} adlValidations additional already-processed validations to use
 * @return {object}               the validator config for this level
 */
export default function formatValidators(validatorVals, path, fields, $refs, adlValidations) {
	// make an empty object to hold validation config
	let validators = Object.assign({}, adlValidations);

	// each field in this level
	for (let field in fields) {
		// get the validator configs for it
		let f_vals = validatorVals[field];
		// add the field to the path
		let this_path = path.concat(field);

		// if the validator configs is another object, run the formatter on it as a new level
		if (f_vals && f_vals.length === undefined) {
			// send this object and this path
			validators[field] = formatValidators(f_vals, this_path, fields[field], $refs);
			continue;
		}

		// if it's only supposed to validate fields that exist, skip the field if it doesn't
		if($refs && $refs[field] === undefined) {
			continue;
		}

		// always add a submission error validator
		validators[field] = validators[field] || {};
		validators[field].submitted = submitted(this_path);

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
			case 'presence':
				// presence validators are called 'blank' for translation purposes
				validators[field].blank = required;
				break;
			case 'length':
				// length validators based on max and min
				if (opts.maximum) {
					validators[field].too_long = maxLength(opts.maximum);
				}
				if (opts.minimum) {
					validators[field].too_short = minLength(opts.minimum);
				}
				break;
			case 'confirmation':
				// a confirmation validator will look for a match on a field with '_confirmation' appended to it
				var conf_field = field + '_confirmation';

				// only add this validator if the confirmation field is also on the form
				if(fields[conf_field] === undefined) {
					break;
				}

				validators[conf_field] = validators[conf_field] || {};
				validators[conf_field].confirmation = sameAs(field);
				break;
			case 'uniqueness':
				// validate it on the server
				validators[field].taken = validateWithServer(this_path.join('.'), 'uniqueness');
				break;
			case 'require_unless_valid':
				// validate that this or the other field exist
				validators[field].one_of = requireUnlessValid(opts.path);
				break;
			case 'acceptance':
				var acceptedField = field.replace('_group', '');
				validators[field].acceptance = acceptance(acceptedField);
				break;
			}
		}
	}
	return validators;
}
