<template>
	<div class="double-prog-bar" :id="id">
		<div class="benchmark" :style="benchmarkStyle" :id="id + '-benchmark'"></div>
		<div class="fill" :style="progStyle" :id="id + '-fill'"></div>
	</div>
</template>

<script>
/**
 * A progress bar component
 *
 * @module
 * @vue-prop benchmark {number} 					the value of the benchmark (a secondary value marker on the progress bar that is represented by a line at the value's location on the bar)
 * @vue-prop progress {number} 						the value of the progress bar, i.e. the amount to fill the bar
 * @vue-prop max {number} 								the maximum value of the bar
 * @vue-prop min=0 {number} 							the minimum value of the bar
 * @vue-prop middle {number} 							the middle value of the bar. only necessary when the bar is log-scaled
 * @vue-prop id=progbar {string} 					the id to assign to the bar
 * @vue-prop logScale=false {boolean} 		should the bar use an exponential scale rather than a linear one?
 * @vue-computed benchmarkStyle {object} 	the style to apply to the benchmark if there is one
 * @vue-computed progStyle {object} 			the style to apply to the progress fill
 */
export default {
	props: {
		benchmark: {
			type: Number,
			default: -1
		},
		progress: Number,
		max: Number,
		min: {
			type: Number,
			default: 0
		},
		middle: Number,
		id: {
			type: String,
			default: 'progbar'
		},
		logScale: Boolean,
	},
	computed: {
		benchmarkStyle: function() {
			if (this.benchmark < 0) {return {display: 'none'};}
			return {left: `${this.getPosition(this.benchmark)}%`};
		},
		progStyle: function() {
			return {width: `${this.getPosition(this.progress)}%`};
		},
	},
	methods: {
		/**
		 * get the position of a value as a percentage of the bar's width
		 *
		 * @param  {number} value the value
		 * @return {number}       the percentage
		 */
		getPosition: function(value) {
			let position = 0;
			// minimum value should be just a bit away from the start end of the bar
			if (value <= this.min) {
				position = 2;
			}
			// if it should be log scaled
			else if (this.logScale) {
				// get the middle
				let middle = this.middle || (this.max-this.min)/2;
				// find the values for the quadratic equation to use
				const b = Math.pow(2, 1/(this.max - middle));
				const a = 100/Math.pow(b, this.max);
				// plug in the value
				position =  Math.ceil(a * Math.pow(b, value));
			} else {
				// otherwise use a linear equation
				position = (value - this.min) * 100 / (this.max - this.min);
			}

			// clamp it between 0 and 100
			return Math.min(Math.max(0, position), 100);
		}
	}
};
</script>
