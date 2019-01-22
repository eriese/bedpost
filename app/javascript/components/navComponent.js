import {TimelineMax, TweenMax} from "gsap/TweenMax"

let navComponent = {
	data: function() {
		return {
			isOpen: false,
			timeLine: null
		}
	},
	mounted() {
		this.$refs.menu.style.display = "block"
		this.timeLine = new TimelineMax()
		this.timeLine.to(this.$refs.menu, 0.3, {width: 0})
		this.timeLine.set(this.$refs.menu, {display: "none", immediateRender: false});
		this.timeLine.progress(1);
	},
	methods: {
		openMenu() {
			this.isOpen = true;
			this.timeLine.reverse();
			document.body.addEventListener('click', this.documentClick)
		},
		closeMenu() {
			this.isOpen = false;
			this.timeLine.play();
			document.body.removeEventListener('click', this.documentClick)
		},
		documentClick(e) {
			let menu = this.$refs.menu;
			let target = e.target;
			if (target.tagName == "A" || (menu !== target & !menu.contains(target))) {
				this.closeMenu()
			}
		},
		toggleMenu() {
			if (this.isOpen) {
				this.closeMenu();
			} else {
				this.openMenu();
			}
		}

	}
}

export default navComponent;
