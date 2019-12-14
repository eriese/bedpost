<template>
	<button :class="['toggle']" @click="doToggle" type="button" :aria-pressed="pressed" :aria-expanded="expanded">{{toggleState}}</button>
</template>

<script>
/**
 * A component to put a toggle button in a form
 *
 * @module
 * @vue-prop {String|String[]} [symbols = ["-", "+"]] Strings to use to represent the values of the toggle. The symbol indexes should map the to vals indexes
 * @vue-prop {Array} [vals=[true,false]] values the toggle toggles to. Toggling increases the value index by 1 and then loops around to 0
 * @vue-prop {Boolean|String|Number|Object} val the current value of the toggle
 * @vue-prop {Boolean|String} [translate=false] should the symbols be translated? If a string is passed it will be used as the translation scope
 * @vue-prop {Boolean|String} [clear=false] should toggling also clear a field on the form? True clears the field of the same name as the toggle, a string will clear the field at the given path
 * @vue-prop {String} field the field that is being toggled
 * @vue-prop {Array} [clearOn] an array of values that should clear the field supplied by clear. If this property is not supplied, all toggles will clear the clear field
 * @vue-prop {Boolean} [expandable=false] does this toggle expand a menu?
 * @vue-computed {String} toggleState the label taken from symbols to describe the toggle's current state
 * @vue-computed {Number} index the index the current value has in the vals array
 * @vue-computed {Boolean} expanded is the menu this toggle expands exapnded?
 * @vue-computed {Boolean} expanded should screen readers read this button as pressed?
 * @emits module:components/form/ToggleComponent~toggle-mounted
 */
export default {
	name: 'toggle',
	data: function() {
		return {};
	},
	props: {
		symbols: {
			type: [Array, String],
			default: function() {
				return ['-', '+'];
			}
		},
		val: [Boolean, String, Number, Object],
		translate: {
			type: [Boolean, String],
			default: false
		},
		vals: {
			type: Array,
			default: function() {
				return [true, false];
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
		},
	},
	computed: {
		toggleState: function() {
			let key = typeof this.symbols == 'string' ? this.symbols : this.symbols[this.index];
			if (this.translate) {
				return this.translate === true ? this.$_t(key) : this.$_t(key, {scope: this.translate});
			}

			return key;
		},
		index: function() {
			// look for the current value in the vals array
			if (this.val !== undefined) {
				return this.vals.indexOf(this.val);
			}

			// otherwise, look for the first falsy value
			for (let i = 0; i < this.vals.length; i++) {
				if (!this.vals[i]) {
					return i;
				}
			}

			// default to 0
			return 0;
		},
		expanded: function() {
			if (!this.expandable) {return;}
			// return a boolean string
			return (!!this.val).toString();
		},
		pressed: function() {
			// return a boolean string
			return (!!this.val).toString();
		}
	},
	methods: {
		/**
		 * Toggle to the next value
		 *
		 * @emits module:components/form/ToggleComponent~toggle-event
		 */
		doToggle() {
			let new_ind = this.index + 1;
			// loop around to 0 if need be
			if (new_ind == this.vals.length) {
				new_ind = 0;
			}

			// get the new value
			let new_val = this.vals[new_ind];
			// check if this toggle should clear
			let clear = null;
			if (this.clear && (this.clearOn === undefined || this.clearOn.indexOf(new_val) >= 0)) {
				clear = this.clear;
			}
			// emit the event
			this.$emit('toggle-event', this.$attrs.field, new_val,clear);
		}
	},
	mounted: function() {
		this.$emit('toggle-mounted');
		if (process.NODE_ENV !== 'production') {
			// check for mismatched symbols and values ammount
			if (typeof this.symbols == 'object' && this.symbols.length != this.vals.length) {
				console.warn('Toggle component has a mismatched number of values and symbols');
			}
		}
	}
};

/**
 * An event to toggle a state
 *
 * @event module:components/form/ToggleComponent~toggle-event
 * @property {string} field the field to toggle
 * @property {boolean|string} newVal the value to set the toggled field to
 * @property {?string} clearField the name of the field that is cleared with this toggle
 */

/**
 * An event to announce that a toggle component has been mounted
 *
 * @event module:components/form/ToggleComponent~toggle-mounted
 */
</script>
