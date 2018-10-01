let navComponent = {
	data: function() {
		console.log("nav connected")
		return {
			isOpen: false
		}
	},
	// props: {
	// 	isOpen: {
	// 		default: false,
	// 		required: false
	// 	}
	// },
	template: "<div></div>",
	methods: {
		openMenu() {
			this.isOpen = !this.isOpen;
		}
	}
}

export default navComponent;
