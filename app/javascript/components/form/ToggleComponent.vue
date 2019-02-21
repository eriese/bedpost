<template>
	<button class="toggle not-button" @click="doToggle" type="button" :aria-pressed="pressed" :aria-expanded="expanded">{{toggleState}}</button>
</template>

<script>
	/**
	 * A component to put a toggle button in a form
	 * @module
	 * @vue-prop {String|String[]} symbols
	 */
	export default {
		name: "toggle",
		data: function() {
			return {}
		},
		props: {
			symbols: {
				type: [Array, String],
				default: function() {
					return ["-", "+"]
				}
			},
			val: [Boolean, String, Number, Object],
			translate: {
				type: Boolean,
				default: false
			},
			vals: {
				type: Array,
				default: function() {
					return [true, false]
				}
			},
			clear: {
				type: [Boolean, String],
				default: false
			},
			clearOn: {
				type: Array,
				required: false
			},
			expandable: {
				type: Boolean,
				required: false
			}
		},
		computed: {
			toggleState: function() {
				let key = typeof this.symbols == "string" ? this.symbols : this.symbols[this.index]
				return this.translate ? I18n.t(key) : key
			},
			index: function() {
				if (this.val !== undefined) {
					return this.vals.indexOf(this.val);
				}

				for (let i = 0; i < this.vals.length; i++) {
					if (!this.vals[i]) {
						return i;
					}
				}
			},
			expanded: function() {
				if (!this.expandable) {return;}
				return (!!this.val).toString();
			},
			pressed: function() {
				return (!!this.val).toString();
			}
		},
		methods: {
			doToggle() {
				let new_ind = this.index + 1;
				if (new_ind == this.vals.length) {
					new_ind = 0;
				}

				let new_val = this.vals[new_ind]
				let clear = false;
				if (this.clear && (this.clearOn === undefined || this.clearOn.indexOf(new_val) >= 0)) {
					clear = this.clear
				}
				this.$emit("toggle-event", this.$attrs.field, new_val,clear)
			}
		},
		mounted: function() {
			if (typeof this.symbols == "object" && this.symbols.length != this.vals.length) {
				console.warn("Toggle component has a mismatched number of values and symbols");
			}
		}
	}
</script>
