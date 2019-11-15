<template>
	<div id="encounter-calendar">
		<div v-if="partnerships.length > 1">
			<v-select v-model="selectedPartners" multiple :options="availablePartners" label="display" :close-on-select="false" :no-drop="empty" :searchable="!empty">
				<template v-slot:selected-option="opt">
					<span><span :class="`partnership-${opt.index}`" class="partner-indicator"></span>{{opt.display}}</span>
				</template>
			</v-select>
		</div>
		<v-calendar v-bind="calendarProps">
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
			let partnerships = Object.values(gon.partnerships)
			return {
				partnerships,
				selectedPartners: partnerships
			}
		},
		computed: {
			calendarProps() {
				return {
					maxDate: new Date(),
					toPage: this.mostRecent,
					isExpanded: true,
					// isDark: true,
					columns: this.$screens({md: 2, lg: 3}, 1),
					attributes: this.selectedEncounters
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
			selectedEncounters() {
				// highlight if there's only one partner
				let highlight = this.selectedPartners.length == 1;
				let ret = [];

				// for each selected partner
				for (let i = 0; i < this.selectedPartners.length; i++) {
					let partner = this.selectedPartners[i];
					// each partner gets their own class, tied to their index in the partnership array so it doesn't change as selectedPartner changed
					let partnerClass = `partnership-${partner.index}`

					// for each of the partner's encounters
					for (var j = 0; j < partner.encounters.length; j++) {
						let enc = partner.encounters[j];


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
					}
				}

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

				// ridiculously, v-calendar wants the calendar number of the month rather than the 0-index
				return {month: max.getMonth() + 1, year: max.getFullYear()};
			}
		},
		methods: {
			/**
			 * toggle a partner's selected status
			 * @param  {String} partnerID the id of the partner
			 */
			togglePartner(partnerID) {
				let partnerInd = this.selectedPartners.indexOf(partnerID);
				// if the partner isn't selected
				if (partnerInd == -1) {
					// select it
					this.selectedPartners.push(partnerID)
				} else {
					// otherwise remove it
					this.selectedPartners.splice(partnerInd, 1);
				}

				// if selected partners is now empty, put all the partners in
				if (this.selectedPartners.length == 0) {
					this.selectedPartners = Object.keys(this.partnerships)
				}
			},
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
