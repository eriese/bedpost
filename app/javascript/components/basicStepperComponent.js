import {animOut, animIn, processClickData} from "../modules/transitions";

export default {
	name: "basic_stepper",
	data: function () {
		return {
			step: 0
		}
	},
	props: {
		stepClass: String,
		animate: {
			type: Boolean,
			default: true
		},
		defaultProps: {
			type: Object
		}
	},
	methods: {
		setStep(newStep, animProps) {
			let props = Object.assign({}, this.defaultProps, animProps)
			processClickData(props)
			animOut(() => {
				this.step = newStep;
				this.$nextTick(animIn)
			});
		}
	}
}
