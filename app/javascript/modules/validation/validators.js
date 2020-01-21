import {helpers} from 'vuelidate/lib/validators';
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
		fieldError = this.submissionError && this.submissionError[path[path.length - 1]];

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
let invalidVals = {};

/**
 * Reset the validator cache
 */
export const resetValidatorCache = () => {
	lastValidVals = {};
	invalidVals = {};
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

	// get the cache key
	const cacheKey = `validateWithServer-${path}-${url}`;
	// set up the invalid cache without replacing an existing cache
	invalidVals[cacheKey] = invalidVals[cacheKey] || {};

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
			// get the response message for the specified path only
			let message = Object.getAtPath(response.data, path);

			// if no message was given for that path
			if (message === undefined) {
				// cache this as a valid value
				lastValidVals[cacheKey] = value;
				resolve(true);
			}

			// set the message based on the response data
			responseMessage.message = message;

			// cache it as an invalid value
			invalidVals[cacheKey] = invalidVals[cacheKey] || {};

			invalidVals[cacheKey][value] = responseMessage.message;

			// the field is invalid
			resolve(false);
		}).catch(() => { resolve(false); });	// any errors count as invalid
	};

	// make the validator
	return helpers.withParams({
		type: 'serverValidated',
		url,
		requestParams: params,
		path,
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
		if (value == '' || value === null || value == lastValidVals[cacheKey]) return true;

		// return false if the value is already in the invalid cache
		if (cacheKey in invalidVals && value in invalidVals[cacheKey]) {
			responseMessage.message = invalidVals[cacheKey][value];
			return false;
		}

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
