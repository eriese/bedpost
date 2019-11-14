import {Radar} from 'vue-chartjs'

const lineColor = 'rgba(0,0,0,0.4)'
const defaultOptions = {

}

export default {
	name: 'partnership-chart',
	extends: Radar,
	props: {
		partnership: Object
	},
	computed: {
		chartData() {
			let labels = [], data = [];
			for(var f in this.partnership) {
				labels.push(f)
				data.push(this.partnership[f])
			}

			return {
			  labels,
			  datasets: [{
			    data,
			    backgroundColor: 'rgba(169,30,132,0.5)',
			    borderColor: 'rgba(169,30,132,0.8)',
			    pointRadius: 5,
			    pointBackgroundColor: 'rgba(169,30,132,1)'
			  }]
			}
		},
		chartOptions() {
			let vm = this
			return {
				legend: {
					display: false
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
						color: lineColor
					},
					gridLines: {
						color: lineColor
					},
					pointLabels: {
						fontSize: 12,
						callback: function(label) {
							return vm.$_t(label, {scope: 'partnerships.show.fields.short'})
						}
					}
				},
				tooltips: {
					displayColors: false,
					callbacks: {
						title: function(tooltipItems, data) {
							return vm.$_t(data.labels[tooltipItems[0].index], {scope: 'helpers.label.partnership'});
						},
						label: function(tooltipItem, data) {
							let labelVal = data.labels[tooltipItem.index]
							return vm.$_t(`helpers.sliders.partnership.${labelVal}`, {count: tooltipItem.value,
								defaults: [{scope: 'helpers.sliders'}]
							});
						}
					}
				}
			}
		}
	},
	mounted() {
		this.renderChart(this.chartData, this.chartOptions);
		this.$refs.canvas.setAttribute('aria-label', this.$_t('partnerships.show.chart.aria_label'));
	}
}
