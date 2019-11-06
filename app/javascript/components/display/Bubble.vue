<template>
	<div class="bubble-container">
		<div v-show="targetEl" class="bubble" :class="[addClass, cls]" :style="stl" ref="bubble">
			<slot></slot>
			<div class="arrow"></div>
		</div>
	</div>
</template>

<script>
	export default {
		data: function() {
			return {
				cls: "",
				stl: {},
				debounce: null,
				targetEl: undefined
			}
		},
		props: {
			target: String,
			position: String,
			padding: {
				type: Number,
				default: 0
			},
			addClass: String
		},
		methods: {
			onSize() {
				let rect = Utils.getBoundingDocumentRect(this.targetEl, true);
				let elRect = Utils.getBoundingDocumentRect(this.$el)

				let pos = {};
				switch (this.position) {
					case "centerX":
					pos.left = rect.centerX;
					break;
					case "right":
					pos.left = rect.right;
					break;
				}

				let bubWidth = this.$refs.bubble.offsetWidth;
				let bubHeight = this.$refs.bubble.offsetHeight;

				if (pos.left !== undefined)  {
					pos.left -= elRect.left;

					if (pos.left + bubWidth > elRect.width) {
						if (pos.left - bubWidth < 0) {
							pos.left -= bubWidth / 2;
							this.cls = "center-justify"
						} else {
							pos.left -= bubWidth;
							this.cls = "right-justify";
						}
					} else {
						this.cls = "left-justify";
					}


					pos.left += "px";
				}

				if (pos.top !== undefined) {
					pos.top += "px";
				}


				this.stl = pos
			},
			debounceTargetEl() {
				this.clearDebounce();
				this.debounce = requestAnimationFrame(this.getTargetEl);
			},
			clearDebounce() {
				if (this.debounce) {
					cancelAnimationFrame(this.debounce);
				}
			},
			getTargetEl() {
				let hadEl = this.targetEl;
				this.targetEl = hadEl || document.getElementById(this.target);

				if (hadEl) {
					this.onSize();
				} else if (this.targetEl) {
					this.$nextTick(this.onSize)
				} else {
					this.debounceTargetEl();
				}
			}
		},
		mounted() {
			let resizeListener = window.addEventListener('resize', this.debounceTargetEl);

			this.$once('hook:beforeDestroy', () => {
				window.removeEventListener('resize', resizeListener);
				this.clearDebounce();
			})

			this.getTargetEl();
		}
	}
</script>
