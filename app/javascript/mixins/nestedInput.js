export default {
	props: {
		value: [Object, String, Number, Boolean, Date],
	},
	computed: {
		model: {
			get() {return this.value},
			set(v) {
				this.$emit("input", v);
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
