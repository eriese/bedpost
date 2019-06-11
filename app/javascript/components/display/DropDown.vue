<template>
	<div class="dropdown" :class="{'title-as-button': titleButton}">
		<span class="dropdown-title" @click="toggle(true)"><slot name="title"></slot></span>
		<span class="dropdown-button" @click="toggle(false)">
			<slot name="button" v-bind="{isOpen}"><arrow-button :class="$attrs['arrow-class']" :direction="isOpen ? 'up' : 'down'"></arrow-button></slot>
		</span>
		<div v-show="isOpen" ref="content" class="dropdown-content">
			<slot></slot>
		</div>
	</div>
</template>

<script>
import {TweenMax} from "gsap/TweenMax";

export default {
	data: function() {
		return {
			isOpen: false
		}
	},
	props: {
		titleButton: {
			type: Boolean,
			default: false
		},
		startOpen: Boolean
	},
	methods: {
		toggle(isTitle) {
			if (isTitle && !this.titleButton) {
				return;
			}

			if (this.isOpen) {
				TweenMax.to(this.$refs.content, 0.3, {height: "0px", overflow: "hidden", clearProps: "height,overflow", onComplete: ()=> {this.isOpen = false}})
				TweenMax.to(this.$el, 0.3, {className: "-=open"});
			} else {
				this.isOpen = true;
				TweenMax.from(this.$refs.content, 0.3, {height: "0px", overflow: "hidden", clearProps: "height,overflow"});
				TweenMax.to(this.$el, 0.3, {className: "+=open"});
			}
		}
	},
	mounted() {
		if (this.startOpen) {
			this.isOpen = true;
		}
	}
}
</script>
