<template>
	<div class="calendar-explainer">
		<slot v-bind="{calendarListeners, handleKey}"></slot>
		<p class="keyboard-only" v-html="calendarInstructions" id="calendar-key-instructions" v-show="doShow"></p>
	</div>
</template>

<script>
export default {
	name: 'calendar-explainer',
	props: ['showInstructions'],
	data() {
		return {
			calendarInstructions: null,
			focused: false,
			calendar: true,
			nearestAttr: 0,
			calendarListeners: {
				dayfocusin: (day) => {
					this.focused = true;
					day.el.setAttribute('aria-describedby', 'calendar-key-instructions');

					if (day.attributes) {
						console.log(day);
						day.el.setAttribute('role', 'button');
						day.el.setAttribute('aria-expanded', true);
						day.el.setAttribute('aria-owns', 'day-popover');
						day.el.setAttribute('aria-pressed', true);
					}
				},
				dayfocusout: () => {this.focused = false;},
			}
		};
	},
	watch: {
		calendarEl(newCal) {
			this.attachToCalendar(newCal);
		},
	},
	computed: {
		calendarEl() {
			return (this.calendar && this.calendar.$el) || (this.datepicker && this.datepicker.$refs.popover.content[0].elm);
		},
		doShow() {
			return this.showInstructions && this.focused;
		},

	},
	methods: {
		attachToCalendar(cal) {
			if (cal == undefined) { return; }

			const keyInstructions = cal.dataset.helptext;
			if (keyInstructions === null) { return; }

			this.calendarInstructions = keyInstructions.replace(/, /g, ',<br>');

			cal.querySelectorAll('.vc-arrows-container.title-center [role=button').forEach((b) => b.setAttribute('tabindex', -1));
		},
		handleKey(e) {
			// const day = this.calendar.lastFocusedDay;

			let newDate = null;
			switch (e.key) {
			case 'z':
				newDate = this.calendar.attributes[this.nearestAttr].dates;
				break;
			}
			if (newDate) {
				event.preventDefault();
				this.calendar.setFocusedDate(newDate);
			}
		}
	},
	mounted() {
		this.$nextTick(() => {
			this.calendar = this.$children.find((c) => c.$options.name == 'Calendar');
			this.attachToCalendar(this.calendarEl);
		});
	}
};
</script>
