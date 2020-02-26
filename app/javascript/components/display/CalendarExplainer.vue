<template>
	<div class="calendar-explainer">
		<slot v-bind="{calendarListeners, handleKey}"></slot>
		<p class="keyboard-only keyboard-instructions" :class="{'keyboard-instructions--has-datepicker': isDatePicker}" id="calendar-key-instructions" v-show="doShow">
			Press the arrow keys to navigate by day,
			<br><span class="keyboard-instructions__key">Home</span> and <span class="keyboard-instructions__key">End</span> to navigate to week ends,
			<br><span class="keyboard-instructions__key">PageUp</span> and <span class="keyboard-instructions__key">PageDown</span> to navigate by month,
			<br><span class="keyboard-instructions__key">Alt</span>+<span class="keyboard-instructions__key">PageUp</span> and <span class="keyboard-instructions__key">Alt</span>+<span class="keyboard-instructions__key">PageDown</span> to navigate by year
			<span v-if="calDates"><br><span class="keyboard-instructions__key">Z</span> and <span class="keyboard-instructions__key">X</span> to jump to the next or previous marked date</span>
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
			calendar: null,
			isDatePicker: true,
			nearestAttr: 0,
			calendarListeners: {
				... this.$listeners,
				dayfocusin: (day) => {
					this.focused = true;
					day.el.setAttribute('aria-describedby', 'calendar-key-instructions');

					if (day.attributes) {
						if (!this.isDatePicker) {
							day.el.setAttribute('role', 'button');
							day.el.setAttribute('aria-expanded', true);
							day.el.setAttribute('aria-owns', 'day-popover');
							day.el.setAttribute('aria-pressed', true);
						}
					}

					if(this.isDatePicker) {
						day.el.setAttribute('role', 'option');
						day.el.setAttribute('aria-selected', !!day.attributes);
					}
				},
				dayfocusout: () => {this.focused = false;},
				popoverDidShow: (popoverEl) => {
					if(this.isDatePicker) {
						popoverEl.parentElement.setAttribute('role', 'presentation');
						popoverEl.setAttribute('role', 'listbox');
						popoverEl.querySelectorAll('.vc-grid-cell, .vc-grid-container, .vc-day, .vc-relative').forEach((el) => {
							el.setAttribute('role', 'presentation');
						});

						popoverEl.querySelectorAll('.vc-day-content.vc-focusable').forEach((el) => {
							el.setAttribute('role', 'option');
							el.setAttribute('aria-describedby', 'calendar-key-instructions');
							el.setAttribute('aria-selected', el.getAttribute('tabindex') == 0);
						});
					}
				}
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

			if(this.isDatePicker) {
				// this.calendar.$refs.popover.$el.setAttribute('role', 'listbox');
				// this.calendar.$refs.popover
			}
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
			this.calendar = this.$children.find((c) => c.$options.name.match(/(Calendar|DatePicker)/));
			this.isDatePicker = this.calendar.$options.name == 'DatePicker';
			this.attachToCalendar(this.calendarEl);
		});
	}
};
</script>
