<template>
	<component :is="componentType" @hook:mounted="checkTour" name="tour" :steps="steps" :callbacks="callbacks" ref="tour-el">
		<template slot-scope="tour">
			<transition name="fade">
				<v-step
					v-if="tour.currentStep === index"
					v-for="(step, index) of tour.steps"
					:key="index"
					:step="step"
					:previous-step="tour.previousStep"
					:next-step="tour.nextStep"
					:stop="tour.stop"
					:is-first="tour.isFirst"
					:is-last="tour.isLast"
					:labels="tour.labels"
				>
					<div slot="actions">
						<div class="v-step__buttons">
							<button @click.prevent="tour.stop" v-if="!tour.isLast" class="cta cta--inverse cta--compact v-step__cta">{{ tour.labels.buttonSkip }}</button>
							<button @click.prevent="tour.previousStep" v-if="!tour.isFirst" class="cta cta--inverse cta--compact v-step__cta">{{ tour.labels.buttonPrevious }}</button>
							<button @click.prevent="tour.nextStep" v-if="!tour.isLast" class="cta cta--inverse cta--compact v-step__cta">{{ tour.labels.buttonNext }}</button>
							<button @click.prevent="tour.stop" v-if="tour.isLast" class="cta cta--inverse cta--compact v-step__cta">{{ tour.labels.buttonStop }}</button>
						</div>
					</div>
				</v-step>
			</transition>
		</template>
	</component>
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
