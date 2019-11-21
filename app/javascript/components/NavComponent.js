import { gsap } from 'gsap';
import renderless from '@mixins/renderless';

/**
 * The nav menu component
 *
 * @module
 * @vue-data {Boolean} isOpen=false is the navigation menu open?
 * @vue-data {timeline} timeLine the animation timeline for opening and closing
 */
export default {
	data: function() {
		return {
			isOpen: false,
			timeLine: null,
			menu: null
		};
	},
	props: ['inner'],
	mixins: [renderless],
	computed: {
		slotScope: function() {
			return {
				isOpen: this.isOpen,
				openMenu: this.openMenu,
				toggleMenu: this.toggleMenu
			};
		}
	},
	// on component mounted
	mounted() {
		this.menu = this.$scopedSlots.default()[0].context.$refs.menu;
		// display the menu so the timeline can get correct data about its starting state
		this.menu.style.display = 'block';
		// make a new timeline
		this.timeLine = gsap.timeline();
		// tween the width till it's closed
		this.timeLine.to(this.menu, 0.3, {width: 0});
		// then set display none
		this.timeLine.set(this.menu, {display: 'none', immediateRender: false});
		// set the timeline to complete
		this.timeLine.progress(1);
	},
	methods: {
		/**
		 * Open the menu and add a click-outside listener {@link module:components/navComponent.documentClick}
		 *
		 * @listens document.body.click
		 */
		openMenu() {
			this.isOpen = true;
			// play the timeline in reverse
			this.timeLine.reverse();
			// listen for clicks on the body for a click-out close
			document.body.addEventListener('click', this.documentClick);
		},
		/**
		 * Close the menu
		 */
		closeMenu() {
			this.isOpen = false;
			// play to timeline forward
			this.timeLine.play();
			// stop listening for click outside
			document.body.removeEventListener('click', this.documentClick);
		},
		/**
		 * React to a click on the document while the menu is open.
		 * Close the menu if the click was on a menu link or outside the menu element
		 *
		 * @param  {Event} e the click event
		 */
		documentClick(e) {
			let menu = this.menu;
			let target = e.target;
			// if the target is a link or not on the menu, close it
			if (target.tagName == 'A' || (menu !== target & !menu.contains(target))) {
				this.closeMenu();
			}
		},
		/**
		 * Toggle the menu's open state
		 */
		toggleMenu() {
			if (this.isOpen) {
				this.closeMenu();
			} else {
				this.openMenu();
			}
		}

	}
};
