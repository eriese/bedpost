<template>
	<div class="calendar-explainer">
		<slot v-bind="{calendarListeners, handleKey}"></slot>
		<p class="keyboard-only" id="calendar-key-instructions" v-show="doShow">
			Press the arrow keys to navigate by day,
			<br>Home and End to navigate to week ends,
			<br>PageUp and PageDown to navigate by month,
			<br>Alt+PageUp and Alt+PageDown to navigate by year
			<br>Z and X to jump to the next or previous marked date
		</p>
	</div>
</template>

<script>
export default {
	name: 'calendar-explainer',
	props: ['showInstructions'],
	data() {
		return {
			focused: false,
			calendar: true,
			nearestAttr: 0,
			calendarListeners: {
				dayfocusin: (day) => {
					this.focused = true;
					day.el.setAttribute('aria-describedby', 'calendar-key-instructions');

					if (day.attributes) {
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
		calDates() {
			return this.calendar && this.calendar.attributes;
		},
	},
	methods: {
		setNearest(newIndex) {
			if (newIndex < 0) {
				this.nearestAttr = this.calDates.length - 1;
			} else if (newIndex >= this.calDates.length) {
				this.nearestAttr = 0;
			} else {
				this.nearestAttr = newIndex;
			}
		},
		attachToCalendar(cal) {
			if (cal == undefined) { return; }

			cal.querySelectorAll('.vc-arrows-container.title-center [role=button').forEach((b) => b.setAttribute('tabindex', -1));
		},
		handleKey: async function(e) {
			const curDate = this.calendar.lastFocusedDay && this.calendar.lastFocusedDay.dateTime;
			if (!this.calDates || !curDate) {
				return;
			}

			let newInd = this.nearestAttr;
			let newDate = null;

			switch (e.key) {
			case 'z':
				newInd = this.calDates.findIndex((d) => new Date(d.dates).setHours(0,0,0,0,) < curDate);
				newInd = newInd == -1 ? this.calDates.length : newInd;
				this.setNearest(newInd);
				newDate = this.calDates[this.nearestAttr].dates;
				break;
			case 'x':
				newInd = this.calDates.findLastIndex((d) => new Date(d.dates).setHours(0,0,0,0,) > curDate);
				this.setNearest(newInd);
				newDate = this.calDates[this.nearestAttr].dates;
				break;
			}

			if (newDate) {
				event.preventDefault();
				this.calendar.showPageRange(newDate);
				setTimeout(() => {
					this.calendar.setFocusedDate(newDate);
				}, 200);
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
