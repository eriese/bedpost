/**
 * Adds necessary properties and event emitters for a component that will handle v-model on an input in its scoped slot
 * @mixin inputSlot
 * @see [FieldErrorsComponent]{@link module:components/form/FieldErrorsComponent} for an implementation example
 */
export default {
	props: {
		value: [Object, String, Number, Boolean, Date],
	},
	computed: {
		model: {
			get() {return this.value},
			/** @emits input */
			set(v) {
				this.$emit("input", v);
			}
		},
		inputSlotScope() {
			return {
				model: this.model,
				$listeners: this.$listeners
			}
		}
	}
}
