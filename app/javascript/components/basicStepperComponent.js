export default {
	name: "basic_stepper",
	data: function () {
		return {
			step: 0
		}
	},
	props: {
		stepClass: String
	},
	methods: {
		setStep(newStep) {
			this.step = newStep;
		}
	}
}
