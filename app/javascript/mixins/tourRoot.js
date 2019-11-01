import TourHolder from "@components/tour/TourHolder.vue"
import axios from 'axios'

/**
 * Adds the data and methods necessary for being the parent component to tour components {@link module:components/tour/TourButton TourButton} and {@link module:components/tour/TourHolder TourHolder}
 * @mixin tourRoot
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
		setTourSteps() {
			this.tourSteps = this.tourData && this.tourData.tour_nodes;
		},
		onTourStop() {
			this.tourSteps = null;
			axios.put(this.tourPage)
		},
		loadTour: async function() {
			if (this.hasTour && this.tourData) {
				this.setTourSteps();
				return;
			}

			let response = await axios.get(this.tourPage, {
				params: {force: this.hasTour}
			});

			if (response.data.has_tour !== false) {
				// if there is a tour
				// show the tour button on the page
				this.hasTour = true;

				// if a tour was returned
				if(response.data.tour_nodes) {
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
