import TourHolder from "@components/tour/TourHolder.vue"
import TourButton from "@components/tour/TourButton.vue"
const importTourComponent = (compName) => {
	return () => import(/* webpackChunkName: "v-tour", webpackPrefetch: true */ `vue-tour/src/components/${compName}.vue`)
}

export const tourData = {
	tourSteps: null,
	tourPlays: 0
}

export const setTourSteps = function(newSteps) {
	this.tourSteps = newSteps;
	this.tourPlays++;
}

/**
 * A plugin that installs vue-tour and its components
 * Basically copied from vue-tour's plugin, but using dynamic imports
 * @module
 */
export default {
	install(Vue, options) {
		// Object containing Tour objects (see VTour.vue) where the tour name is used as key
		Vue.prototype.$tours = {}

		// add the TourHolder and TourButton components
		Vue.component('tour-holder', TourHolder);
		Vue.component('tour-button', TourButton);

		// Dynamically load v-step
		// v-tour is loaded dynamically in TourHolder
		Vue.component('v-step', importTourComponent('VStep'));
	}
}
