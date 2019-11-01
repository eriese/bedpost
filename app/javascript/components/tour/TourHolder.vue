<template>
	<component :is="componentType" @hook:mounted="checkTour" name="tour" :steps="steps" :callbacks="callbacks"/>
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

	export default {
		data: function() {
			return {
				running: false,
				callbacks: {
					onStart: this.onStart,
					onStop: this.onStop
				}
			}
		},
		props: {
			steps: Array,
			plays: Number
		},
		computed: {
			componentType: function() {
				return this.steps ? VTour : emptyGuide
			}
		},
		watch: {
			plays: function(newVal) {
				if (newVal > 1) {
					this.startTour();
				}
			}
		},
		methods: {
			checkTour() {
				if (this.steps) {
					this.startTour()
				}
			},
			startTour() {
				if (!this.running) {
					this.$tours.tour.start()
				}
			},
			onStart() {
				this.running = true;
			},
			onStop() {
				this.running = false;
			}
		}
	}
</script>
