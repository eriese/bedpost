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
			if (response.data === true) resolve(true);

			// set the message based on the response data
			responseMessage.message = Object.getAtPath(response.data, path);
			// the field is invalid
			resolve(false);
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
		if (value == '' || value === null) return true;

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
