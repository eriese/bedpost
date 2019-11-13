<template>
	<div>
		<div v-show="!requested">
			<slot :click-handler="toggleRequest"></slot>
		</div>
		<div v-show="fetching">{{$_t("loading")}}</div>
		<div v-show="requested && fetchedHTML">
			<div v-html="fetchedHTML"></div>
			<button type="button" class="not-button" @click="toggleRequest">{{toggleBack}}</button>
		</div>
	</div>
</template>

<script>
	import axios from 'axios';

	export default {
		name: 'content-requester',
		data() {
			return {
				requested: false,
				fetchedHTML: null,
				fetching: false
			}
		},
		props: {
			cache: {
				type: Boolean,
				default: true,
			},
			toggleBack: String
		},
		methods:{
			async toggleRequest(e) {
				e.preventDefault();
				if (this.fetching) {return;}

				this.fetching = true;
				if (this.requested === false) {
					if (!this.cache || !this.fetchedHTML) {
						let response = await axios.get(e.target.href)
						this.fetchedHTML = response.data;
					}
				}

				this.requested = !this.requested;
				this.fetching = false;
			}
		}
	}
</script>
