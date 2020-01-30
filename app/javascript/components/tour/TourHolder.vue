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
							<button @click.prevent="tour.stop" v-if="!tour.isLast" class="cta cta--inverse cta--is-compact v-step__cta">{{ tour.labels.buttonSkip }}</button>
							<button @click.prevent="tour.previousStep" v-if="!tour.isFirst" class="cta cta--inverse cta--is-compact v-step__cta">{{ tour.labels.buttonPrevious }}</button>
							<button ref="next-button" @click.prevent="tour.nextStep" v-if="!tour.isLast" class="cta cta--inverse cta--is-compact v-step__cta">{{ tour.labels.buttonNext }}</button>
							<button ref="next-button" @click.prevent="tour.stop" v-if="tour.isLast" class="cta cta--inverse cta--is-compact v-step__cta">{{ tour.labels.buttonStop }}</button>
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
					onNextStep: this.onNext,
				},
				stepOptions: {
					modifiers: {
						preventOverflow: {
							boundariesElement: 'viewport'
						}
					}
				},
				previouslyActive: null
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
						buttonStop: this.$_t('button_stop', {scope: 'tours.show', count: this.steps.length}),
						buttonSkip: this.$_t('button_skip', {scope: 'tours.show'}),
						buttonNext: this.$_t('button_next', {scope: 'tours.show'}),
						buttonPrevious: this.$_t('button_previous', {scope: 'tours.show'}),
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
					// tell the parent that a tour has started
					this.$emit('tour-started');
					// if it hasn't run before on this page, wait 2 seconds to run
					let timeoutNum = this.tourRuns > 0 ? 0 : 2000
					this.timeout = setTimeout(() => {
						// if we have to wait for the step target to come into view, make an intersection observer
						if (this.steps[0].await_in_view) {
							this.observer = new IntersectionObserver(this.startTour, {threshold: [1]});
							this.firstStepTarget = document.querySelector(this.steps[0].target)
							this.observer.observe(this.firstStepTarget)
						} else {
							// otherwise just start
							this.startTour();
						}
					}, timeoutNum);
				}
			},
			/**
			 * starts the tour if there is one
			 */
			startTour(entries) {
				this.previouslyActive = document.activeElement;
				// start if the first step is visible
				let entriesVisible = entries && entries[0].isIntersecting
				let firstVisibility = this.firstStepTarget && getComputedStyle(this.firstStepTarget).visibility;
				if (!entries || (entriesVisible && firstVisibility == 'visible')) {
					this.tour && this.tour.start();
					this.focusButton();
				}
			},
			/**
			 * emit that the tour has stopped
			 * @emits tour-stopped
			 */
			onStop() {
				this.$emit('tour-stopped');
				this.previouslyActive && this.previouslyActive.focus();
				this.previouslyActive = null;
			},
			onNext(currentStep) {
				this.$emit('next-step', currentStep + 1);
				this.focusButton();
			},
			focusButton() {
				setTimeout(() => {
					this.$refs['next-button'][0].focus();
				}, 50)
			}
		},
		beforeDestroy() {
			this.observer && this.observer.disconnect();
			clearTimeout(this.timeout);
		}
	}
</script>
