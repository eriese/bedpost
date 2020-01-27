<template>
	<div>
		<div v-show="!requested">
			<slot :click-handler="toggleRequest"></slot>
		</div>
		<div v-show="fetching">{{$_t("loading")}}</div>
		<div v-show="requested && fetchedHTML">
			<div v-html="fetchedHTML"></div>
			<button type="button" :class="['link', $attrs['toggle-class']]" @click="toggleRequest">{{toggleBack}}</button>
		</div>
	</div>
</template>

<script>
	import axios from 'axios';

	/**
	 * A container that toggles between slotted content and requested loaded
	 * @module
	 * @vue-data {Boolean} requested=false should the requested content be showing?
	 * @vue-data {String} fetchedHtml=null the loaded html content
	 * @vue-data {Boolean} fetching=false is the component currently waiting for the requested content to load?
	 * @vue-prop {Boolean} cache=true should the component cache loaded content (i.e. load only on the first request)
	 * @vue-prop {String} url the url for the request if it will not be passed from the click event
	 * @vue-prop {String} toggleBack the text for the button to toggle back to the slotted content
	 */
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
				default: true
			},
			url: String,
			toggleBack: String
		},
		methods:{
			async toggleRequest(e) {
				e.preventDefault();
				// essentially disable the click element while waiting on the request
				if (this.fetching) {return;}
				this.fetching = true;

				// if we're not currently looking at requested content
				if (this.requested === false) {
					// and we've never loaded the requested content or are meant to reload every time
					if (!this.cache || !this.fetchedHTML) {
						// get the requested content
						let response = await axios.get(e.target.href || this.url)
						this.fetchedHTML = response.data;
					}
				}

				// toggle views
				this.requested = !this.requested;
				this.fetching = false;
			}
		}
	}
</script>
