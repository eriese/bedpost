export default {
	props: ['baseName', 'label', 'labelKey', 'model'],
	computed: {
		cListeners: function() {
			let vm = this;
			let inputEvent = this.$options.model && this.$options.model.event || "input"
			let newListeners = {};
			newListeners[inputEvent] = function(e) {
				vm.$emit(inputEvent, e.target.value);
			}
			return Object.assign({}, this.$listeners, newListeners);
		},
		modelName: function() {
			return this.model || (this.$vnode.data.model && this.$vnode.data.model.expression) || "";
		},
		inputName: function() {
			return this.modelName === "" ? null : `${this.baseName}[${this.modelName}]`;
		},
		inputId: function() {
			return `${this.baseName}${this.modelName}${this.inputValue || ""}`;
		},
		labelText: function() {
			return this.label || this.$_t(this.labelKey);
		}
	},
	created: function() {
		if (!this.inputValue) {
			this.inputValue = undefined;
		}
	},
	mounted: function() {
		if (process.NODE_ENV !== 'production' && !this.$vnode.data.model) {
			console.warn(`Custom input field ${this.$vnode.tag} does not have a v-model directive on it.`)
		}
	}
}
