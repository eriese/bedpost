<template>
	<div class="errors" v-if="formErrors">{{formErrors}}</div>
</template>

<script>
	export default {
		name: "form_errors",
		data: function () {
			return {}
		},
		props: {
			submissionError: Object
		},
		computed: {
			formErrors: function() {
				let err = this.submissionError.form_error

				if (err && typeof err.join == "function") {
					err = err.join(I18n.t("join_delimeter"))
				}

				return err;
			}
		}
	}
</script>
