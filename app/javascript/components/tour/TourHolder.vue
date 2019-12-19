<template>
	<component :is="componentType" @hook:mounted="checkTour" name="tour" :steps="steps" :callbacks="callbacks" :options="tourOptions" ref="tour-el">
		<template slot-scope="tour">
			<transition name="fade">
				<v-step
					v-if="tour.currentStep === index"
					v-for="(step, index) of tour.steps"
					:key="index"
					:step="{...step, params: stepOptions}"
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
					onStop: this.onStop,
				},
				stepOptions: {
					modifiers: {
						preventOverflow: {
							boundariesElement: 'viewport'
						}
					}
				}
			}
		},
		props: {
			steps: Array,
			tourRuns: Number
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
			},
			tourOptions() {
				if (!this.steps) {return {};}

				return {
					labels: {
						buttonStop: this.steps.length == 1 ? 'Got it' : 'Finish'
					}
				}
			},
		},
		methods: {
			/**
			 * checks to see if a tour should run when a new component mounts
			 */
			checkTour() {
				if (this.tour && !this.running) {
					this.$emit('tour-started');

					let timeoutNum = this.tourRuns > 0 ? 0 : 2000
					this.timeout = setTimeout(() => {
						if (this.steps[0].await_in_view) {
							this.observer = new IntersectionObserver(this.startTour, {threshold: [1]});
							this.firstStepTarget = document.querySelector(this.steps[0].target)
							this.observer.observe(this.firstStepTarget)
						} else {
							this.startTour();
						}
					}, timeoutNum);
				}
			},
			/**
			 * starts the tour if there is one
			 */
			startTour(entries) {
				let firstVisibility = this.firstStepTarget && getComputedStyle(this.firstStepTarget).visibility;
				if (!entries || firstVisibility == 'visible') {
					this.tour && this.tour.start()
				}
			},
			/**
			 * emit that the tour has stopped
			 * @emits tour-stopped
			 */
			onStop() {
				this.$emit('tour-stopped');
			},
		},
		beforeDestroy() {
			this.observer && this.observer.disconnect();
			clearTimeout(this.timeout);
		}
	}
</script>
