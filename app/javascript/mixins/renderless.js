/**
 * Allows a component to render a scoped slot with no template
 * @mixin renderless
 */
export default {
	render: function() {
		let scope = this.slotScope
		if (this.slotScope == undefined) {
			console.warn(`Renderless component ${this.$options.name} should implement a prop or computed property called "slotScope". Defaulting to empty scope`);
			scope = {};
		}

		return this.$scopedSlots.default(scope);
	}
}
