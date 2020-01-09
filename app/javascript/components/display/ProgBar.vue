<template>
	<div class="double-prog-bar" :id="id">
		<div class="benchmark" :style="benchmarkStyle" :id="id + '-benchmark'"></div>
		<div class="fill" :style="progStyle" :id="id + '-fill'"></div>
	</div>
</template>

<script>
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
		getPosition: function(value) {
			let position = 0;
			if (value <= this.min) {
				position = 2;
			}
			else if (this.logScale) {
				let middle = this.middle || (this.max-this.min)/2;
				const b = Math.pow(2, 1/(this.max - middle));
				const a = 100/Math.pow(b, this.max);
				position =  Math.ceil(a * Math.pow(b, value));
			} else {
				position = (value - this.min) * 100 / (this.max - this.min);
			}

			return Math.min(Math.max(0, position), 100);
		}
	}
};
</script>
