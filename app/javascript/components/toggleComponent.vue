<template>
	<button class="toggle not-button" @click="doToggle" type="button">{{toggleState}}</button>
</template>

<script>
	export default {
		name: "toggle",
		data: function() {
			return {}
		},
		props: {
			symbols: {
				type: Array,
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
			}
		},
		computed: {
			toggleState: function() {
				let key = this.symbols[this.index]
				return this.translate ? I18n.t(key) : key
			},
			index: function() {
				return this.vals.indexOf(this.val);
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
		}
	}
</script>
