<template>
	<div class="bubble-container">
		<div v-show="targetEl" class="bubble" :class="[addClass, cls]" :style="stl" ref="bubble">
			<slot></slot>
			<div class="arrow"></div>
		</div>
	</div>
</template>

<script>
import resizeable from '@mixins/resizeable';

/**
 * A component that shows an explanation bubble with a pointer to the given target element. Automatically positions itself based on the given position property
 *
 * @module
 * @vue-data {String} cls="" classes applied to the bubble element for positioning
 * @vue-data {Object} stl={} style applied to the bubble element for positioning
 * @vue-data {Timeout} debounce the id of the debounce timeout
 * @vue-data {HTMLElement} targetEl the element the bubble is pointing to
 * @vue-prop {String} target the css selector of the element the bubble should point to
 * @vue-prop {String} position the position on the target element that the bubble should point to. (e.g. 'right' will make it point to the right edge of the target element)
 * @vue-prop {String} addClass any classes to add to the bubble element
 */
export default {
	mixins: [resizeable],
	data: function() {
		return {
			cls: '',
			stl: {},
			targetEl: undefined
		};
	},
	props: {
		target: String,
		position: String,
		addClass: String
	},
	methods: {
		/**
		 * Set the position of the bubble
		 */
		setPosition() {
			// get bounding rects for the target and the bubble container element
			let targetRect = Utils.getBoundingDocumentRect(this.targetEl, true);
			let elRect = Utils.getBoundingDocumentRect(this.$el);

			// initialize an empty position object
			let pos = {};
			// set position starting point based on the position prop
			switch (this.position) {
			case 'centerX':
				// point to target centerX
				pos.left = targetRect.centerX;
				break;
			case 'right':
				// point to target right
				pos.left = targetRect.right;
				break;
			// TODO implement more positions as needed
			}

			let bubWidth = this.$refs.bubble.offsetWidth;
			// let bubHeight = this.$refs.bubble.offsetHeight;

			if (pos.left !== undefined)  {
				// compensate for element offset
				pos.left -= elRect.left;

				// if the bubble will not fit in the element based on current left
				if (pos.left + bubWidth > elRect.width) {
					// if the bubble will also not fit on the other side of the current left
					if (pos.left - bubWidth < 0) {
						// center the bubble around the current left
						pos.left -= bubWidth / 2;
						this.cls = 'center-justify';
					} else {
						// otherwise put it all the way to right of the current left
						pos.left -= bubWidth;
						this.cls = 'right-justify';
					}
				} else {
					// if it will fit, left-justify
					this.cls = 'left-justify';
				}


				// set it to pixels
				pos.left += 'px';
			}

			// if (pos.top !== undefined) {
			// 	pos.top += "px";
			// }

			// set it as the style
			this.stl = pos;
		},
		/**
		 * get the target element and set the position if it is found
		 */
		onSize() {
			// only get it if it hasn't already been found
			this.targetEl = this.targetEl || document.getElementById(this.target);

			// if it's there, set the position
			if (this.targetEl) {
				this.setPosition();
			} else {
				// otherwise try again after the debounce window
				this.debounceOnSize();
			}
		}
	},
};
</script>
