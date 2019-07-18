<template>
	<button type="button" :aria-pressed="`${isSelected}`" :aria-label="ariaLabel" v-on="$listeners" :class="[`partnership-${partner.index}`]" class="encounter-contact-toggle">{{partner.display}}</button>
</template>

<script>
	export default {
		name: 'encounter-contact-toggle',
		props: ['selected', 'partner'],
		computed: {
			ariaLabel() {
				return this.$root.t(`is_${this.isSelected}`, {scope: 'encounters.index.toggle_partner', partner_name: this.partner.display})
			},
			isSelected() {
				return this.selected.indexOf(this.partner._id) >= 0;
			}
		}
	}
</script>
