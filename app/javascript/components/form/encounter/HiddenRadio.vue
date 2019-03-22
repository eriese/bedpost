<template>
	<div class="input">
		<input ref="input" type="radio" class="hidden-radio" :value="value" v-on="listeners" :name="`${baseName}[${model}]`" :id="baseName + model + value">
		<label :for="baseName + model + value">{{label || $root.t(labelKey)}}</label>
	</div>
</template>

<script>
	export default {
		name: "hidden_radio",
		props: ["baseName", "value", "model", "labelKey", "label", "checked"],
		model: {
			prop: 'checked'
		},
		computed: {
			listeners: function() {
				let vm = this;
				return Object.assign({}, this.$listeners, {
					input: function(e) {
						vm.$emit('input', e.target.value);
					}
				})
			}
		},
		updated: function() {
			// have to put this here instead of on the dom because for some reason, it doesn't stick when you change the order of the contact fields
			this.$refs.input.checked = this.checked == this.value;
		}
	}
</script>
