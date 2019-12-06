<template>
	<component :is="componentType" @hook:mounted="checkTour" name="tour" :steps="steps" :callbacks="callbacks" ref="tour-el"/>
</template>

<script>
	/**
	 * an empty component to use a placeholder
	 * @type {Object}
	 */
	const emptyGuide = {
		render(createElement) {
			return createElement("div", {
				attrs: {
					class: "tourguide-empty"
				}
			})
		}
	}

	const VTour = () => import(/* webpackChunkName: 'vendors/v-tour.tour', webpackPrefetch: true */"vue-tour/src/components/VTour.vue")

	/**
	 * A component to load {@link https://pulsar.gitbooks.io/vue-tour/ vue-tour} and run the tour.
	 * Uses an empty placeholder child instead of loading the library if there is no tour
	 * @module
	 */
	export default {
		data: function() {
			return {
				callbacks: {
					onStop: this.onStop
				}
			}
		},
		props: {
			steps: Array
		},
		computed: {
			componentType: function() {
				return this.steps ? VTour : emptyGuide
			},
			tour() {
				return this.steps ? this.$refs['tour-el'].$tours.tour : null;
			},
			running() {
				return this.tour && this.tour.isRunning
			}
		},
		methods: {
			/**
			 * checks to see if a tour should run when a new component mounts
			 */
			checkTour() {
				if (this.steps && !this.running) {
					this.startTour();
				}
			},
			/**
			 * starts the tour if there is one
			 */
			startTour() {
				this.tour && this.tour.start()
			},
			/**
			 * emit that the tour has stopped
			 * @emits tour-stopped
			 */
			onStop() {
				this.$emit('tour-stopped');
			}
		}
	}
</script>
