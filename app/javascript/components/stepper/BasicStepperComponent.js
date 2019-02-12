import {animOut, animIn, processClickData} from "../../modules/transitions";


/**
 * A component that allows you to put steps on a page and animate navigation
 * @module
 * @vue-data {number} step=0 the step the stepper is currently showing
 * @vue-prop {Boolean} [animate=true] whether step transitions should animate
 * @vue-prop {module:transitions.prop_overrides} [defaultProps] default animation props to apply to animations
 *
 * @example
 * <caption>It's easiest to put the stepper in your html with an inline template. Then use v-ifs to separate your steps,
 * and call {@link module:components/basicStepperComponent.setStep} to change steps</caption>
 * <basic-stepper inline-template :default-props="{animLength: 0.2}">
 * 	<div v-if="step == 0">
 * 		I'm the first step
 * 		<button type="button" @click="setStep(1, {animationType: 'slideLeft'})">Go to the second step</button><
 * 	</div>
 * 	<div v-if="step == 1">
 * 		I'm the second step
 * 		<button type="button" @click="setStep(0, {animationType: 'slideRight'})">Go back to the first step</button>
 * 	</div>
 * </basic-stepper>
 * @example
 * <caption>You can also put it on the page using a scoped slot.</caption>
 * <basic-stepper>
 * 	<div slot-scope={step, setStep}>
 * 		... see above example
 * 	</div>
 * </basic-stepper>
 *
 */
export default {
	name: "basic_stepper",
	data: function () {
		return {
			step: 0
		}
	},
	props: {
		animate: {
			type: Boolean,
			default: true
		},
		defaultProps: {
			type: Object
		}
	},

	methods: {
		/**
		 * set what step the stepper is on (click handler for navigation)
		 * @function
		 * @param {number} newStep   the index of the step to go to
		 * @param {module:transitions.prop_overrides} [animProps= module:components/basicStepperComponent.props.defaultProps] properties to use in the transition animation
		 */
		setStep(newStep, animProps) {
			if (!this.animate) {
				this.step = newStep;
				return;
			}
			let props = Object.assign({}, this.defaultProps, animProps)
			processClickData(props)
			animOut(() => {
				this.step = newStep;
				this.$nextTick(animIn)
			});
		}
	},
	// render without template
	render: function() {
		return this.$scopedSlots.default({
			step: this.step,
			setStep: this.setStep
		})
	}
}
