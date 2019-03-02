import {helpers} from 'vuelidate/lib/validators'
/**
 * Custom [Vuelidate]{@link https://monterail.github.io/vuelidate/} validators
 * @module validators
 */

/**
 * Make a validator that checks whether the field has a submission error
 * @param  {String[]} path the path to the field in the object
 * @return {Boolean}      whether there is a submission error at this path and the current value matches the errored value
 */
export const submitted = (path) => {
	// hold onto the value that caused the error
	let erroredVal = undefined;
	// hold onto the previous error
	let prevError = undefined

	// make the validator
	return helpers.withParams({type: "submissionError", path: path}, function (value) {
		let fieldError = undefined;

		// look for the field in the submission error
		fieldError = this.submissionError[path[path.length - 1]]

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
	})
}
