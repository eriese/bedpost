<template>
	<div class="input" role="presentation">
		<input ref="input" type="radio" class="hidden-radio" :value="inputValue" v-on="cListeners" :name="inputName" :id="inputId" :class="['hidden-radio', `hidden-radio--${$attrs.type}`]">
		<label :for="inputId">{{labelText}}</label>
	</div>
</template>

<script>
import customInput from '@mixins/customInput';

export default {
	name: 'hidden_radio',
	props: ['checked', 'inputValue'],
	mixins: [customInput],
	inheritAttrs: false,
	model: {
		prop: 'checked',
		event: 'change'
	},
	computed: {
		inputProperty: () => 'value',
	},
	methods: {
		setChecked() {
			if (this.checked == undefined || this.inputValue == undefined) {
				return;
			}
			// have to do this manually instead of on the dom because for some reason, it doesn't stick when you change the order of the contact fields
			this.$refs.input.checked = this.checked == this.inputValue || this.checked.toString() == this.inputValue.toString();
		}
	},
	updated: function() {
		this.setChecked();
	},
	mounted: function() {
		this.setChecked();
	}
};
</script>
