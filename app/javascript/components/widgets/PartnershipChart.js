import {Radar} from 'vue-chartjs';
import sassColors from '@modules/sassColors';

/** the color for grid and angle lines on the chart */
const lineColor = 'rgba(0,0,0,0.4)';
/** default chart options */
const defaultOptions = {
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
		},
		angleLines: {
			color: lineColor,
		},
		gridLines: {
			color: lineColor,
		},
		pointLabels: {
			fontSize: 12,
		},
	},
	tooltips: {
		displayColors: false,

	},
};

/**
 * get the data color at the given opacity
 *
 * @param  {number|string} opacity the opacity of the color
 * @return {string}         the full rgba color declaration
 */
const dataColor = (opacity) => sassColors.asRgba('backgroundColorSecondary', opacity);
/** {object} default properties for the dataset */
const datasetDefaults = {
	backgroundColor: dataColor(0.5),
	borderColor: dataColor(0.8),
	pointRadius: 5,
	pointBackgroundColor: dataColor(1),
};

/**
 * A component that wraps and mounts a [radar chart]{@link https://www.chartjs.org/docs/latest/charts/radar.html} to display partnership values
 *
 * @module
 * @vue-prop {object} partnership 	the partnership this chart will display
 * @vue-data {object} chartData 		the data points for the chart
 * @vue-data {object} chartOptions 	the configuration for the chart
 */
export default {
	name: 'partnership-chart',
	extends: Radar,
	props: {
		partnership: Object,
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
					...datasetDefaults
				}],
			};
		},
		chartOptions() {
			let vm = this;
			let options = {
				...defaultOptions
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
		this.renderChart(this.chartData, this.chartOptions);
		// add an aria label indicating that this information is also available as a table
		this.$refs.canvas.setAttribute('aria-label', this.$_t('partnerships.show.chart.aria_label'));
	},
};
