/**
 * Add a debounced reaction to window resize events
 * @mixin resizeable
 * TODO mix this into bubble after bubble fixes are merged
 * REQUIRES AN `onSize` METHOD TO WORK.
 */
export default {
	data() {
		return {
			debounce: null
		}
	},
	methods: {
		debounceOnSize() {
			this.clearDebounce();
			this.debounce = setTimeout(this.onSize, this.debounceTime || 50);
		},
		clearDebounce() {
			this.debounce && clearTimeout(this.debounce);
		}
	},
	created() {
		if (process.NODE_ENV !== 'production') {
			if (this.onSize == undefined) {
				console.warn(`Resizeable compoenent does ${this.$options.name} does not implement an onSize function, so it will not react to window resize events`);
				this.onSize = function() {}
			}
		}
	},
	mounted() {
		// debounce repositioning on window resize
		let resizeListener = window.addEventListener('resize', this.debounceOnSize);
		// remove the resize listener on destroy
		this.$once('hook:beforeDestroy', () => {
			window.removeEventListener('resize', resizeListener);
			// clear existing debounce timeouts
			this.clearDebounce();
		})

		this.onSize();
	}
}
