/**
 * A plugin that installs vue-tour and its components
 * Basically copied from {@link https://pulsar.gitbooks.io/vue-tour/ vue-tour}'s plugin, but using dynamic imports
 * @module
 */
export default {
	install(Vue, options) {
		// Object containing Tour objects (see VTour.vue) where the tour name is used as key
		Vue.prototype.$tours = {}

		// Dynamically load v-step
		// v-tour is loaded dynamically in TourHolder
		Vue.component('v-step', () => import(/* webpackChunkName: 'vendors/v-tour.step', webpackPrefetch: true */ 'vue-tour/src/components/VStep.vue'));
	}
}
