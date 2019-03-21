export default {
	props: ["baseName", "watchKey", "value"],
	watch: {
		watchKey: function() {
			let func = this.onKeyChange
			if (func) {
				if (typeof func == "function") {
					func()
				} else {
					this[func[0]].call(func[1]);
				}
			} else if (process.NODE_ENV !== 'production' && func === undefined) {
				console.warn(`Dynamic Field List Item Component ${this.$options.name} does not implement onKeyChange. If you're having problems with it after list mutation, implementing one might fix it. To get rid this warning, set onKeyChange to false`);
			}
		}
	},
	methods: {
		blur() {},
		focus() {},
		focusFirst() {
			this.focus();
			let first = this.getFirstInput()
			if (first) {
				first.focus();
			}
		},
		getFirstInput() {
			return this.$el.querySelector("input");
		}
	},
	computed: {
		_value: function() {
			return Object.assign({}, this.value);
		}
	}
}
