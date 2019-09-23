<template>
	<div v-show="targetEl" class="bubble-container">
		<div class="bubble" :class="[addClass, cls]" :style="stl" ref="bubble">
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
				this.targetEl = this.targetEl || document.getElementById(this.target);
				if (!this.targetEl) {
					this.debounce = setTimeout(this.onSize, 50);
					return;
				}
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
			}
		},
		mounted() {
			this.$nextTick(() => {
				let resizeListener = window.addEventListener('resize', () => {
					if (this.debounce) {
						clearTimeout(this.debounce);
					}
					this.debounce = setTimeout(() => {
						this.stl = {left: 0, top: 0};
						this.$nextTick(this.onSize)
					}, 50);
				});

				this.$once('hook:beforeDestroy', () => {
					window.removeEventListener('resize', resizeListener);
					if (this.debounce) {
						clearTimeout(this.debounce);
					}
				})

				this.onSize()
				this.debounce = setTimeout(this.onSize, 50);
			})
		},
		destroyed() {
			if (this.debounce) {}
		}
	}
</script>
