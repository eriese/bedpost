<template>
	<div class="bubble" :style="{height: heightVal}">
		<tippy v-bind="tippyProps" ref="tippy" v-if="mounted">
			<slot></slot>
		</tippy>
	</div>
</template>

<script>
import { TippyComponent } from 'vue-tippy';
import ArrowModifier from '@plugins/popperModifiers/arrow';

/**
 * A component that shows an explanation bubble with a pointer to the given target element. Uses vue-tippy
 *
 * @module
 * @vue-data {number} heightVal the height the element needs to make space for the tippy
 * @vue-computed {object} tippyProps options to pass to the tippy component
 */
export default {
	components: {
		tippy: TippyComponent,
	},
	data() {
		return {
			heightVal: undefined,
			mounted: false,
		};
	},
	props: {
		target: String,
		position: {
			type: String,
			default: 'bottom'
		},
		theme: {
			type: String,
			default: 'light'
		},
	},
	computed: {
		tippyProps() {
			return {
				appendTo: () => this.$el,
				arrow: true,
				boundary: 'scrollParent',
				flip: false,
				multiple: true,
				theme: this.theme,
				trigger: 'manual',
				hideOnClick: false,
				visible: true,
				toSelector: `#${this.target}`,
				placement: this.position,
				onMount: this.setHeight,
				popperOptions: {
					modifiers: {
						arrow: {
							fn: ArrowModifier
						},
					}
				}
			};
		},
	},
	methods: {
		setHeight() {
			this.heightVal = `${this.$refs.tippy.tip.popper.offsetHeight}px`;
		}
	},
	mounted() {
		requestAnimationFrame(() => {
			this.mounted = true;
		});
	}
};
</script>
