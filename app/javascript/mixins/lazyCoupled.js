/**
 * Marks a component as lazy-loaded and required for its parent's setup. Emits 'lazy-child-present' on its parent when mounted.
 * @mixin lazyChild
 */
const lazyChild = {
	mounted() {
		this.$parent.$emit('lazy-child-present');
	}
};

/**
 * Marks a component as parent to a lazy-loaded component that is required to be mounted before this component can complete setup
 * @mixin lazyParent
 */
const lazyParent = {
	created() {
		let func = this.onChildMounted;
		if (func && typeof func == 'function') {
			this.$once('lazy-child-present', () => {
				this.$nextTick(func);
			});
		} else if (process.NODE_ENV !== 'production' && func === undefined) {
			console.warn(`Lazy loaded parent component ${this.$options.name} does not implement onChildMounted. This could lead to errors if the children need to be processed on mount`);
		}

	}
};

export {lazyParent, lazyChild};
