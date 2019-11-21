<template>
	<div id="encounter-calendar">
		<div v-if="partnerships.length > 1 && hasEncounters">
			<v-select v-model="selectedPartners" multiple :options="availablePartners" label="display" :close-on-select="false" :no-drop="empty" :searchable="!empty">
				<template v-slot:selected-option="opt">
					<span><span :class="`partnership-${opt.index}`" class="partner-indicator"></span>{{opt.display}}</span>
				</template>
			</v-select>
		</div>
		<v-calendar v-if="hasEncounters" v-bind="calendarProps">
			<div slot="day-popover" slot-scope="{ day, dayTitle, attributes }">
				<div class="popover-day-title">
					{{ dayTitle }}
					</div>
					<v-popover-row
						v-for="attr in attributes"
						:key="attr.key"
						:attribute="attr">
						<span class="encounter-partner-name">{{attr.customData.partnerName}}:</span>
						<a :href="`/partners/${attr.customData.partnerID}/encounters/${attr.customData.encID}`">{{ attr.customData.notes}}</a>
				</v-popover-row>
			</div>
		</v-calendar>
		<slot v-if="!hasEncounters" ></slot>
	</div>
</template>

<script>
	/**
	 * A calendar component to display a user's encounters with one or more partners
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
		data() {
			return {
				selectedPartnersArray: this.partnerships,
				hasEncounters: this.partnerships.some((p) => p.encounters && p.encounters.length),
			}
		},
		props: {
			partnerships: Array
		},
		computed: {
			calendarProps() {
				return {
					maxDate: new Date(),
					isExpanded: true,
					// isDark: true,
					columns: this.$screens({md: 2, lg: 3}, 1),
					attributes: this.selectedEncounters,
					toPage: this.mostRecent,
				}
			},
			empty() {
				return this.availablePartners.length == 0;
			},
			availablePartners() {
				// copy all the partners
				let all = this.partnerships.slice()
				for (let i = 0; i < this.selectedPartners.length; i++) {
					// remove any selected partners
					all.splice(all.indexOf(this.selectedPartners[i]), 1)
				}
				return all;
			},
			selectedPartners: {
				get() {
					return this.selectedPartnersArray
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
				this.selectedPartners.forEach((partner, partnerIndex) => {
					if (partner.encounters == undefined) {return;}
					// each partner gets their own class, tied to their index in the partnership array so it doesn't change as selectedPartner changed
					const partnerClass = `partnership-${partner.index}`

					// for each of the partner's encounters
					partner.encounters.forEach((enc, encIndex) => {
						ret.push({
							// the date it took place
							dates: new Date(enc.took_place),
							// add a dot if there's more than one partner
							dot: highlight ? false : partnerClass,
							// add a highlight if there's only one partner
							highlight: highlight ? partnerClass : false,
							// data to pass to the popover
							customData: {
								partnerID: partner._id,
								encID: enc._id,
								partnerName: partner.display,
								notes: enc.notes || this.$_t('encounters.index.no_notes')
							},
							// show popover on focus
							popover: {
								visibility: 'focus'
							}
						})
					})
				})

				return ret;
			},
			mostRecent() {
				// max date
				let max = null;
				// go through the selected encounters
				const mostRecentEncounter = this.selectedEncounters.reduce((prev, curr) => (new Date(prev.dates) > new Date(curr.dates)) ? prev : curr);
				const mostRecentEncounterDate = new Date(mostRecentEncounter.dates)

				// ridiculously, v-calendar wants the calendar number of the month rather than the 0-index
				return {month: mostRecentEncounterDate.getMonth() + 1, year: mostRecentEncounterDate.getFullYear()};

				max = max || new Date();
				// ridiculously, v-calendar wants the calendar number of the month rather than the 0-index
				return {month: max.getMonth() + 1, year: max.getFullYear()};
			}
		},
		methods: {
			/**
			 * is the given partner selected?
			 * @param  {String}  partnerID the id of the partner
			 * @return {Boolean} whether the partner is selected
			 */
			isSelected(partnerID) {
				return this.selectedPartners.indexOf(partnerID) >= 0;
			}
		}
	}
</script>
