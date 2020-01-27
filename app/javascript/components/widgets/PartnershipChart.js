import Chart from 'chart.js';
import {Radar} from 'vue-chartjs';
import sassColors from '@modules/sassColors';

/**
 * Original _drawLabels function from the radialLinear axis
 *
 * @type {function}
 */
const radialLinearDrawLabels = Chart.scaleService.constructors.radialLinear.prototype._drawLabels;

// override the _drawLabels function
Chart.scaleService.constructors.radialLinear.prototype._drawLabels = function() {
	var me = this;
	// get the startAngle
	var originalAngle = me.chart.options.startAngle;
	// set it to 0 for drawing labels
	me.chart.options.startAngle = 0;
	// call the original function
	radialLinearDrawLabels.call(me);
	// set it back to the startAngle
	me.chart.options.startAngle = originalAngle;
};

// Chart.pluginService.register({
// 	beforeDraw: function (chartInstance) {
// 		if (chartInstance.config.options.chartArea && chartInstance.config.options.chartArea.backgroundColor) {
// 			var ctx = chartInstance.chart.ctx;
// 			var chartArea = chartInstance.scale;

// 			ctx.fillStyle = chartInstance.config.options.chartArea.backgroundColor;
// 			ctx.beginPath();
// 			ctx.ellipse(chartArea.xCenter, chartArea.yCenter, chartArea.drawingArea, chartArea.drawingArea, Math.PI / 4, 0, 2 * Math.PI);
// 			ctx.fill();
// 		}
// 	}
// });

/** the color for grid and angle lines on the chart */
const lineColor = () => sassColors.asRgba('text', 1);

/**
 * get the data color at the given opacity
 *
 * @param  {number|string} opacity the opacity of the color
 * @return {string}         the full rgba color declaration
 */
const dataColor = (opacity) => sassColors.asRgba('background-contrast', opacity,);

/**
 * A component that wraps and mounts a [radar chart]{@link https://www.chartjs.org/docs/latest/charts/radar.html} to display partnership values
 *
 * @module
 * @vue-prop {object} partnership 			the partnership this chart will display
 * @vue-data {object} datasetDefaults 	default properties for the dataset
 * @vue-data {object} defaultOptions 		default chart options
 * @vue-computed {object} chartData 		the data points for the chart
 * @vue-computed {object} chartOptions 	the configuration for the chart
 */
export default {
	name: 'partnership-chart',
	extends: Radar,
	props: {
		partnership: Object,
	},
	data() {
		return {
			chart: null,
			datasetDefaults: {
				backgroundColor: dataColor(0.5),
				borderColor: dataColor(0.8),
				pointRadius: 5,
				pointBackgroundColor: dataColor(),
			},
			defaultOptions: {
				legend: {
					display: false,
				},
				startAngle: 36,
				scale: {
					ticks: {
						beginAtZero: true,
						max: 10,
						min: 0,
						stepSize: 2,
						backdropColor: sassColors.asRgba('background'),
						fontColor: sassColors.asRgba('text'),
					},
					angleLines: {
						color: lineColor(),

					},
					gridLines: {
						color: lineColor(),
						circular: true,
					},
					pointLabels: {
						fontSize: 12,
						fontColor: sassColors.asRgba('text', 1),
					},
				},
				tooltips: {
					displayColors: false,
				},
			},
		};
	},
	computed: {
		chartData() {
			let labels = [], data = [];
			for(var f in this.partnership) {
				labels.push(f);
				data.push(this.partnership[f]);
			}

			return {
				labels,
				datasets: [{
					data,
					...this.datasetDefaults
				}],
			};
		},
		chartOptions() {
			let vm = this;
			let options = {
				...this.defaultOptions
			};

			options.scale.pointLabels.callback = function(label) {
				return vm.$_t(label, {scope: 'partnerships.show.fields.short'});
			};

			options.tooltips.callbacks = {
				title: function(tooltipItems, data) {
					return vm.$_t(data.labels[tooltipItems[0].index], {scope: 'helpers.label.partnership'});
				},
				label: function(tooltipItem, data) {
					let labelVal = data.labels[tooltipItem.index];
					return vm.$_t(`helpers.sliders.partnership.${labelVal}`, {
						count: tooltipItem.value,
						defaults: [{scope: 'helpers.sliders'}],
					});
				},
			};

			return options;
		},
	},
	mounted() {
		// render the chart
		this.chart = this.renderChart(this.chartData, this.chartOptions);
		// add an aria label indicating that this information is also available as a table
		this.$refs.canvas.setAttribute('aria-label', this.$_t('partnerships.show.chart.aria_label'));
	},
};
