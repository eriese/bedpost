<template>
	<button v-show="hasTour" type="button" class="tourguide-button" @click="getTour(true)">?</button>
</template>

<script>
	import axios from 'axios'

	export default {
		name: "tour-button",
		data: function() {
			return {
				hasTour: false,
				tourData: null
			}
		},
		methods: {
			getTour: async function (force) {
				if (this.hasTour && this.tourData) {
					this.emitTour();
					return;
				}

				let pageName = `/tours/${window.location.pathname.replace(/\//g, "-")}.json`
				let response = await axios.get(pageName, {params: {force}});

				if (response.data.has_tour !== false) {
					// if there is a tour
					// show the tour button on the page
					this.hasTour = true;

					// if a tour was returned
					if(response.data.has_tour === undefined) {
						this.tourData = response.data
						this.emitTour();
					}
				}
			},
			emitTour() {
				this.$emit("tour", this.tourData.tour_nodes);
			}
		},
		created() {
			this.getTour();
		}
	}
</script>
