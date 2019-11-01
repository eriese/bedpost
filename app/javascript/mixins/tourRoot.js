import TourHolder from "@components/tour/TourHolder.vue"
import axios from 'axios'

/**
 * Adds the data and methods necessary for being the parent component to tour components {@link module:components/tour/TourHolder TourHolder}
 * @mixin tourRoot
 * @vue-data {Object[]} tourSteps=null the steps of the tour
 * @vue-data {Boolean} hasTour=false does the page have a tour?
 * @vue-data {Object} tourData=null the data returned from a request for the page's tour
 * @vue-computed {String} tourPage the string representation of the current page's path for requesting and closing the tour
 * @listens tour-requested
 * @listens tour-stopped
 */
export default {
	data: function() {
		return {
			tourSteps: null,
			hasTour: false,
			tourData: null
		}
	},
	computed: {
		tourPage() {
			return `/tours/${window.location.pathname.replace(/\//g, "-")}.json`
		}
	},
	methods: {
		/**
		 * Set the tour steps from the tour data
		 */
		setTourSteps() {
			this.tourSteps = this.tourData && this.tourData.tour_nodes;
		},
		/**
		 * Empty the tour steps and send a put request to mark the user as having viewed this page's tour
		 * @listens tour-stopped
		 */
		onTourStop() {
			this.tourSteps = null;
			axios.put(this.tourPage)
		},
		/**
		 * Load the tour data if there is any
		 * @listens tour-requested
		 */
		loadTour: async function() {
			// if there's already a tour loaded, just use that
			if (this.tourData) {
				this.setTourSteps();
				return;
			}

			// request the tour data for this page
			let response = await axios.get(this.tourPage, {
				params: {force: this.hasTour}
			});

			// if there is a tour
			if (response.data.has_tour !== false) {

				// show the tour button on the page
				this.hasTour = true;

				// if a tour was returned (the user hasn't seen it before)
				if(response.data.tour_nodes) {
					// save the data and set the steps
					this.tourData = response.data
					this.setTourSteps();
				}
			}
		}
	},
	components: {
		'tour-holder': TourHolder
	},
	created() {
		this.loadTour();
	}
}
