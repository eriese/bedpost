<template>
	<div class="errors" v-if="formErrors">{{formErrors}}</div>
</template>

<script>
	/**
	 * A component to render form submission errors
	 * @module
	 * @vue-prop {Object} submissionError the errors from the last submission attempt on the form
	 * @vue-computed {String} formErrors the errors to display for the form
	 */
	export default {
		name: "form_errors",
		props: {
			submissionError: Object
		},
		computed: {
			formErrors: function() {
				let err = this.submissionError.form_error

				if (err && typeof err.join == "function") {
					err = err.join(this.$_t("join_delimeter"))
				}

				return err;
			}
		}
	}
</script>
