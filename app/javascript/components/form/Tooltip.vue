<template>
	<div class="tooltip">
		<tippy v-if="!showAlways" v-bind="tippyProps">
			<slot></slot>
		</tippy>
		<aside v-else class="tippy-popper" x-placement="bottom">
			<div :class="['tippy-tooltip', `${theme}-theme`]" x-placement="bottom">
				<div class="tippy-arrow"></div>
				<div class="tippy-content">
					<slot></slot>
				</div>
			</div>
		</aside>
	</div>
</template>

<script>
import { TippyComponent } from 'vue-tippy';

export default {
	name: 'tooltip',
	components: {
		tippy: TippyComponent,
	},
	props: {
		theme: {
			type: String,
			default: 'light'
		},
		showAlways: Boolean,
		useScope: Object,
		toSelector: String,
	},
	data() {
		return {
			shouldShow: false,
			showTimeout: null,
			defaultProps: {
				animation: 'shift-away',
				appendTo: () => this.$el,
				arrow: true,
				boundary: 'scrollParent',
				flip: true,
				placement: 'top',
				aria: null,
				toSelector: this.toSelector,
				theme: this.theme,
			}
		};
	},
	watch: {
		fieldFocused(newVal) {
			let delay = newVal ? 500 : 100;

			if(this.showTimeout) {
				clearTimeout(this.showTimeout);
				this.showTimeout = null;
				return;
			}

			this.showTimeout = setTimeout(() => {
				this.shouldShow = !!newVal;
				this.showTimeout = null;
			}, delay);
		}
	},
	computed: {
		fieldFocused() {
			return this.useScope ? this.useScope.focused || this.useScope.hovered : false;
		},
		tippyProps() {
			if (!this.useScope) { return this.defaultProps; }
			return {
				...this.defaultProps,
				trigger: 'manual',
				hideOnClick: false,
				visible: this.shouldShow,
				a11y: false,
			};
		},
	},
};
</script>
