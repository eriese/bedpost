/**
 * Adds the data and methods necessary for being the parent component to tour components {@link module:components/tour/TourButton TourButton} and {@link module:components/tour/TourHolder TourHolder}
 * @mixin tourRoot
 */
import TourHolder from "@components/tour/TourHolder.vue"
import TourButton from "@components/tour/TourButton.vue"

export default {
	data: function() {
		return {
			tourSteps: null
		}
	},
	methods: {
		setTourSteps(newSteps) {
			this.tourSteps = newSteps;
		},
		onTourStop() {
			this.tourSteps = null;
		}
	},
	components: {
		'tour-holder': TourHolder,
		'tour-button': TourButton
	}
}
