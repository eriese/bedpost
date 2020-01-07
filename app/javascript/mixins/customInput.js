import {lazyChild} from '@mixins/lazyCoupled';
/**
 * A mixin for a custom input component
 *
 * @mixin customInput
 * @vue-computed {object} cListeners 	the listeners to apply to the input
 * @vue-computed {string} modelName		the string to add to the baseName to get the inputName for this input
 * @vue-computed {string} inputName 	the value for the name attribute of the input
 * @vue-computed {string} inputId 		the value for the id attribute of the input
 * @vue-computed {string} labelText 	the text for this input's label
 * @mixes lazyChild
 */
export default {
	mixins: [lazyChild],
	props: ['baseName', 'label', 'labelKey', 'model'],
	computed: {
		cListeners: function() {
			let vm = this;
			let newListeners = {};
			newListeners[this.inputEvent] = function(e) {
				let val = e && e.target && e.target[vm.inputProperty];
				vm.$emit(vm.inputEvent, val);
			};
			return Object.assign({}, this.$listeners, newListeners);
		},
		modelName: function() {
			if (this.model) return this.model;
			if (this.$vnode.data.model) {
				let nameSplit = this.$vnode.data.model.expression.split('.');
				return nameSplit[nameSplit.length - 1];
			}

			return '';
		},
		inputName: function() {
			return this.modelName === '' ? null : `${this.baseName}[${this.modelName}]`;
		},
		inputId: function() {
			return `${this.baseName}${this.modelName}${this.inputValue || ''}`.replace(/(\]|\[)+/g, '-');
		},
		labelText: function() {
			return this.label || this.$_t(this.labelKey);
		},
		inputEvent: function() {
			return this.$options.model && this.$options.model.event || 'input';
		},
		inputProperty: function() {
			return this.$options.model && this.$options.model.prop || 'value';
		}
	},
	created: function() {
		if (!this.inputValue) {
			this.inputValue = undefined;
		}
	},
	mounted: function() {
		if (process.NODE_ENV === 'development' && !this.$vnode.data.model) {
			console.warn(`Custom input field ${this.$vnode.tag} does not have a v-model directive on it.`);
		}
	}
};
