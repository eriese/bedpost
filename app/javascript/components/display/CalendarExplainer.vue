<template>
	<p class="keyboard-only" v-html="calendarInstructions"></p>
</template>

<script>
export default {
	name: 'calendar-explainer',
	props: ['calendar', 'container', 'datepicker'],
	data() {
		return {
			calendarInstructions: null,
		};
	},
	watch: {
		calendarEl(newCal) {
			this.attachToCalendar(newCal);
		},
	},
	computed: {
		containerEl() {
			if (!this.container) {
				return this.calendarEl;
			}

			return this.container == 'parent' ? this.$el.parentElement : (this.container.$el || this.container);
		},
		calendarEl() {
			return (this.calendar && this.calendar.$el) || (this.datepicker && this.datepicker.$refs.popover.content[0].elm);
		}
	},
	methods: {
		attachToCalendar(cal) {
			if (cal == undefined) { return; }

			const keyInstructions = cal.dataset.helptext;
			if (keyInstructions === null) { return; }

			this.containerEl.setAttribute('aria-keyshortcuts', keyInstructions);
			this.calendarInstructions = keyInstructions.replace(/, /g, ',<br>');
		}
	},
	mounted() {
		this.attachToCalendar(this.calendarEl);
	}
};
</script>
