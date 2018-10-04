<template>
	<div v-if="v[field].$dirty && v[field].required === false">
          This field is required.
    </div>
    <div v-else-if="v[field].$dirty && v[field].$anyError">
    	Other error
    </div>
</template>

<script>
	export default {
		name: "field-errors",
		data: function() {
			return {}
		},
		props: {
			v: Object,
			field: String
		}
	}
</script>
