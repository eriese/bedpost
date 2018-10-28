<template>
	<div class="errors" v-if="formErrors">{{formErrors}}</div>
</template>

<script>
	export default {
		data: function () {
			return {}
		},
		props: {
			submissionError: Object
		},
		computed: {
			formErrors: function() {
				return this.submissionError.formError || gon.formError
			}
		}
	}
</script>
