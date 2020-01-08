<template>
	<div class="dropdown" :class="{'title-as-button': titleButton, 'dropdown--is-open': isOpen, 'dropdown--is-closed': closing || !isOpen}">
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
import { gsap } from 'gsap';

export default {
	data: function() {
		return {
			isOpen: false,
			closing: false
		};
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
				this.closing = true;
				gsap.to(this.$refs.content, 0.3, {height: '0px', overflow: 'hidden', clearProps: 'height,overflow', onComplete: ()=> {
					this.isOpen = false;
					this.closing = false;
				}});
			} else {
				this.isOpen = true;
				gsap.from(this.$refs.content, 0.3, {height: '0px', overflow: 'hidden', clearProps: 'height,overflow'});
			}
		}
	},
	mounted() {
		if (this.startOpen) {
			this.isOpen = true;
		}
	}
};
</script>
