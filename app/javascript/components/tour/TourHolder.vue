<template>
	<component :is="componentType" @hook:mounted="checkTour" name="tour" :steps="steps" :callbacks="callbacks" ref="tour-el"/>
</template>

<script>
	const emptyGuide = {
		render(createElement) {
			return createElement("div", {
				attrs: {
					class: "tourguide-empty"
				}
			})
		}
	}

	const VTour = () => import(/* webpackChunkName: "v-tour", webpackPrefetch: true */"vue-tour/src/components/VTour.vue")

	/**
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
				this.tour && this.tour.isRunning
			}
		},
		methods: {
			checkTour() {
				if (this.steps && !this.running) {
					this.startTour();
				}
			},
			startTour() {
				this.tour && this.tour.start()
			},
			onStop() {
				this.$emit('tour-stopped');
			}
		}
	}
</script>
