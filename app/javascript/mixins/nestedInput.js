export default {
	props: {
		value: [Object, String, Number, Boolean],
	},
	computed: {
		model: {
			get() {return this.value},
			set(v) {
				this.$emit("input", v);
				console.log(`Setting ${this.$options.name} value to ${v}`)
			}
		},
		nestedSlotScope() {
			return {
				model: this.model,
				$listeners: this.$listeners
			}
		}
	}
}
