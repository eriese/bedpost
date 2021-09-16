<template>
	<div id="encounter-calendar">
		<slot v-if="!hasEncounters" ></slot>
		<div v-else>
			<div v-if="partnerships.length > 1">
				<v-select v-model="selectedPartners" multiple :options="availablePartners" label="display" :close-on-select="false" :no-drop="empty" :searchable="!empty" @input="handleSelect" ref="select">
					<template v-slot:selected-option-container="{option, deselect, multiple, disabled}" >
						<span class="vs__selected" :class="`partnership-${option.index}`">
							<span class="vs__selected-inner">{{option.display}}</span>
							<arrow-button v-if="multiple" :disabled="disabled" @click="deselect(option)" class="vs__deselect" aria-label="Remove option" shape="x" t-key="remove"></arrow-button>
						</span>
					</template>
				</v-select>
			</div>
			<toggle-switch :symbols="['calendar_view', 'list_view']" :translate="'encounters.index'" :vals="['calendar', 'list']" field="viewType" :val="viewType" @toggle-event="onToggle"></toggle-switch>
			<calendar-explainer :calendar="$refs.calendar"  show-instructions="viewType=='calendar'">
			<div class="container--has-contrast-border container--is-centered container--is-rounded encounter-calendar__container" ref="calendar-container" @keydown="explainer.handleKey" role="application" aria-roledescription="Calendar" slot-scope="explainer">
				<v-calendar v-show="viewType == 'calendar'" v-bind="calendarProps" ref="calendar" v-on="explainer.calendarListeners">
					<div slot="day-popover" slot-scope="{ day, dayTitle, attributes }" id="day-popover">
						<div class="popover-day-title">
							{{ dayTitle }}
							</div>
							<v-popover-row
								v-for="attr in attributes"
								:key="attr.customData.encID"
								:attribute="attr">
								<a class="link" :href="attr.customData.href"><b class="encounter-partner-name">{{attr.customData.partnerName}}:</b>{{ attr.customData.notes }}</a>
						</v-popover-row>
					</div>
				</v-calendar>
				<div v-show="viewType=='list'">
					<ul class="encounter-list no-dots container--is-card">
						<encounter-list-item v-for="enc in selectedEncounters" :key="enc.customData.encID" :encounter="enc"></encounter-list-item>
					</ul>
				</div>
			</div>
			</calendar-explainer>
		</div>
	</div>
</template>

<script>
import encounterListItem from '@components/functional/EncounterListItem';
import PopoverRow from 'v-calendar/lib/components/popover-row.umd.min';

/**
 * A calendar component to display a user's encounters with one or more partners
 *
 * @module
 * @vue-data {Array} partnerships the partnership(s) whose encounters will display
 * @vue-data {Array} selectedPartnerships a subset of partnerships selected by the user to show now
 * @vue-computed {Object} calendarProps the properties to pass to the v-calendar component
 * @vue-computed {Boolean} empty are there no available partners?
 * @vue-computed {Array} availablePartners partners who are not in the selectedPartners and can still be selected
 * @vue-computed {Array} selectedEncounters data for the calendar dates from the encounters belonging to the selected partnerships
 * @vue-computed {Object} mostRecent the month and year of the most recent encounter
 */
export default {
	name: 'encounter-calendar',
	components: {
		encounterListItem,
		'v-popover-row': PopoverRow
	},
	data() {
		return {
			selectedPartnersArray: this.partnerships,
			hasEncounters: this.partnerships.some((p) => p.encounters && p.encounters.length),
			viewType: 'calendar',
		};
	},
	props: {
		partnerships: Array
	},
	computed: {
		calendarProps() {
			return {
				maxDate: new Date(),
				isExpanded: true,
				// isDark: document.body.classList.contains('is-dark'),
				columns: this.$screens({md: 2, lg: 3}, 1),
				attributes: this.selectedEncounters,
				toPage: this.mostRecent,
			};
		},
		empty() {
			return this.availablePartners.length == 0;
		},
		availablePartners() {
			// copy all the partners
			let all = this.partnerships.slice();
			for (let i = 0; i < this.selectedPartners.length; i++) {
				// remove any selected partners
				all.splice(all.indexOf(this.selectedPartners[i]), 1);
			}
			return all;
		},
		selectedPartners: {
			get() {
				return this.selectedPartnersArray;
			},
			set(newVal) {
				this.selectedPartnersArray = newVal.length ? newVal : this.partnerships;
			}
		},
		selectedEncounters() {
			// highlight if there's only one partner
			let highlight = this.selectedPartners.length == 1;
			let ret = [];

			// for each selected partner
			this.selectedPartners.forEach((partner) => {
				if (partner.encounters == undefined) {return;}
				// each partner gets their own class, tied to their index in the partnership array so it doesn't change as selectedPartner changed
				const partnerClass = `partnership-${partner.index}`;
				// for each of the partner's encounters
				partner.encounters.forEach((enc, ) => {
					ret.push({
						// the date it took place
						dates: new Date(enc.took_place),
						// add a dot if there's more than one partner
						dot: highlight ? false : {class: partnerClass, color: partnerClass},
						// add a highlight if there's only one partner
						highlight: highlight ? {class: partnerClass, color: partnerClass} : false,
						// data to pass to the popover
						customData: {
							partnerID: partner._id,
							encID: enc._id,
							partnerName: partner.display,
							notes: enc.notes || this.$_t('encounters.index.no_notes'),
							partnerClass: partnerClass,
							href: `/encounters/${enc._id}`
						},
						// show popover on focus
						popover: {
							visibility: 'focus'
						}
					});
				});
			});

			return ret.sort((a, b) => b.dates - a.dates);
		},
		mostRecent() {
			// they're already sorted to have the most recent at the top
			let max = this.selectedEncounters[0].dates;

			max = max || new Date();
			// ridiculously, v-calendar wants the calendar number of the month rather than the 0-index
			return {month: max.getMonth() + 1, year: max.getFullYear()};
		}
	},
	methods: {
	/**
	 * is the given partner selected?
	 *
	 * @param  {string}  partnerID the id of the partner
	 * @return {boolean} whether the partner is selected
	 */
		isSelected(partnerID) {
			return this.selectedPartners.indexOf(partnerID) >= 0;
		},
		onToggle(field, newVal) {
			this[field] = newVal;
		},
		handleSelect() {
			if (this.partnerships.length <= 1) {return;}

			if (this.empty) {
				this.$refs.select.$refs.search.setAttribute('disabled', 'disabled');
			} else {
				this.$refs.select.$refs.search.removeAttribute('disabled');
			}
		}
	},
	mounted() {
		this.handleSelect();
	}
};
</script>
