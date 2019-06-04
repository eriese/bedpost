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
			id: {
				type: String,
				default: "progbar"
			}
		},
		computed: {
			benchmarkStyle: function() {
				if (this.benchmark < 0) {return {display: "none"}}
				return {left: `${this.benchmark * 100 / this.max}%`}
			},
			progStyle: function() {
				return {width: `${this.progress * 100 / this.max}%`}
			}
		}
	}
</script>
