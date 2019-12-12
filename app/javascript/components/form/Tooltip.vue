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
			defaultProps: {
				animation: 'shift-away',
				appendTo: () => this.$el,
				arrow: true,
				boundary: 'viewport',
				delay: [200, 0],
				flip: true,
				placement: 'bottom',
				aria: null,
				toSelector: this.toSelector,
				theme: this.theme,
			}
		};
	},
	computed: {
		tippyProps() {
			if (!this.useScope) { return this.defaultProps; }
			return {
				...this.defaultProps,
				trigger: 'manual',
				hideOnClick: false,
				visible: this.useScope.focused || this.useScope.hovered,
				a11y: false,
			};
		},
	},
};
</script>
