<template>
	<div class="toggle-switch">
		<button class="toggle-switch__btn" type="button" v-for="(btn, i) in displayStrings" :aria-pressed="(index == i).toString()" @click="doToggle(i)" :key="i" :class="$attrs['button-class']">{{btn}}</button>
	</div>
</template>

<script>
import ToggleComponent from '@components/form/ToggleComponent.vue';

export default {
	name: 'toggle-switch',
	extends: ToggleComponent,
	computed: {
		toggleState() {return '';},
		displayStrings() {
			return this.symbols.map((s) => {
				return this.translate ?
					(this.translate == true ? this.$_t(s) : this.$_t(s, {scope: this.translate})) : s;
			});
		},
	},
	methods: {
		doToggle(index) {
			this.onToggle(index);
		}
	}
};
</script>
