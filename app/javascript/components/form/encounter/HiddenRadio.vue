<template>
	<div class="input">
		<input ref="input" type="radio" class="hidden-radio" :value="inputValue" v-on="cListeners" :name="inputName" :id="inputId">
		<label :for="inputId">{{labelText}}</label>
	</div>
</template>

<script>
	import customInput from '@mixins/customInput';

	export default {
		name: "hidden_radio",
		props: ["checked", 'inputValue'],
		mixins: [customInput],
		model: {
			prop: 'checked'
		},
		updated: function() {
			// have to put this here instead of on the dom because for some reason, it doesn't stick when you change the order of the contact fields
			this.$refs.input.checked = this.checked == this.inputValue;
		}
	}
</script>
