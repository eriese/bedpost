let navComponent = {
	data: function() {
		return {
			isOpen: false
		}
	},
	methods: {
		openMenu() {
			this.isOpen = true;
			document.body.addEventListener('click', this.documentClick)
		},
		closeMenu() {
			this.isOpen = false;
			document.body.removeEventListener('click', this.documentClick)
		},
		documentClick(e) {
			let menu = this.$refs.menu;
			let target = e.target;
			if (menu !== target & !menu.contains(target)) {
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
