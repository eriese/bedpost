import TourHolder from '@components/tour/TourHolder.vue';
import axios from 'axios';

/**
 * Adds the data and methods necessary for being the parent component to tour components {@link module:components/tour/TourHolder TourHolder}
 *
 * @mixin tourRoot
 * @vue-data {Object[]} tourSteps=null the steps of the tour
 * @vue-data {Boolean} hasTour=false does the page have a tour?
 * @vue-data {Object} tourData=null the data returned from a request for the page's tour
 * @vue-computed {String} tourPage the string representation of the current page's path for requesting and closing the tour
 * @listens tour-stopped
 */
export default {
	data: function() {
		return {
			tourSteps: null,
			hasTour: false,
			tourData: null,
			tourRunning: false,
			tourRuns: 0,
			currentStep: 0,
			tourPath: null,
			pageTourPath: window.location.pathname.replace(/\//g, '-').replace(window.idRegex, ''),
		};
	},
	computed: {
		tourPage() {
			return `/tours/${this.tourPath}.json`;
		}
	},
	methods: {
		/**
		 * reset the tour to the given page
		 *
		 * @param {string} value the path of this page
		 */
		setTourPath(value) {
			this.tourPath = value;
			this.tourData = null;
			this.hasTour = false;
			this.loadTour();
		},
		/**
		 * Set the tour steps from the tour data
		 */
		setTourSteps() {
			this.tourSteps = this.tourData && this.tourData.tour_nodes;
		},
		/**
		 * Empty the tour steps and send a put request to mark the user as having viewed this page's tour
		 *
		 * @listens tour-stopped
		 */
		onTourStop() {
			this.tourRunning = false;
			if (this.tourSteps && this.currentStep < this.tourSteps.length - 1) {
				this.gtagSet('metric2', 1);
			}
			this.sendAnalyticsEvent(this.tourPage, {
				'event_category': 'Tour Stop',
				'event_label': this.currentStep
			});

			this.tourSteps = null;
			axios.put(this.tourPage).catch(function () {});
		},
		/**
		 * Mark the tour as starting and increment the run count
		 *
		 * @listens tour-started
		 */
		onTourStart() {
			this.tourRunning = true;
			this.tourRuns++;
			this.currentStep = 0;
		},

		/**
		 * When the next button on the tour is pressed
		 *
		 * @param  {number} currentStep the step the tour is now on
		 */
		onTourNext(currentStep) {
			this.currentStep = currentStep;
		},
		/**
		 * Load the tour data if there is any
		 */
		loadTour: async function() {
			if (this.tourPath === null) {
				return;
			}

			if (this.hasTour) {
				this.gtagSet('metric3', 1);
			}

			// if there's already a tour loaded, just use that
			if (this.tourData) {
				this.setTourSteps();
				this.gtagSet('metric3', 1);
			}
			else {

				try {
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
							this.tourData = response.data;
							this.setTourSteps();
						} else {
							this.tourRuns++;
						}

					}
				} catch(e) {
					console.debug(e.response);
				}
			}

			this.sendAnalyticsEvent(this.tourPage, {
				'event_category': 'Tour Start',
			});
		}
	},
	components: {
		'tour-holder': TourHolder
	},
	created() {
		this.tourPath = this.pageTourPath,
		this.loadTour();
	}
};
