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
				    <a :href="`/partners/${attr.customData.partnerID}/encounters/${attr.customData.encID}`">{{ attr.customData.notes || $_t('encounters.index.no_notes')}}</a>
				</v-popover-row>
			</div>
		</v-calendar>
	</div>
</template>

<script>
	import encounterContactToggle from './EncounterContactToggle.vue';

	export default {
		name: 'encounter-calendar',
		components: {
			encounterContactToggle
		},
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
				let all = this.partnerships.slice()
				for (let i = 0; i < this.selectedPartners.length; i++) {
					all.splice(all.indexOf(this.selectedPartners[i]), 1)
				}
				return all;
			},
			selectedEncounters() {
				let highlight = this.selectedPartners.length == 1;
				let ret = [];

				for (let i = 0; i < this.selectedPartners.length; i++) {
					let partner = this.selectedPartners[i];
					// let partner = this.partnerships[partnerID];
					let partnerClass = `partnership-${partner.index}`

					for (var j = 0; j < partner.encounters.length; j++) {
						let enc = partner.encounters[j];

						ret.push({
							dates: enc.took_place,
							dot: highlight ? false : partnerClass,
							highlight: highlight ? partnerClass : false,
							customData: {
									partnerID: partner._id,
									encID: enc._id,
									partnerName: partner.display,
									notes: enc.notes
								},
							popover: {
								visibility: 'focus'
							}
						})
					}
				}

				return ret;
			},
			mostRecent() {
				let max = null;
				for (let i = 0; i < this.selectedEncounters.length; i++) {
					let enc = this.selectedEncounters[i]
					let encDate = new Date(enc.dates)
					if (encDate > max) {
						max = encDate
					}
				}
				// ridiculously, v-calendar wants the calendar number of the month rather than the 0-index
				return {month: max.getMonth() + 1, year: max.getFullYear()};
			}
		},
		methods: {
			togglePartner(partnerID) {
				let partnerInd = this.selectedPartners.indexOf(partnerID);
				if (partnerInd == -1) {
					this.selectedPartners.push(partnerID)
				} else {
					this.selectedPartners.splice(partnerInd, 1);
				}

				if (this.selectedPartners.length == 0) {
					this.selectedPartners = Object.keys(this.partnerships)
				}
			},
			isSelected(partnerID) {
				return this.selectedPartners.indexOf(partnerID) >= 0;
			}
		}
	}
</script>
