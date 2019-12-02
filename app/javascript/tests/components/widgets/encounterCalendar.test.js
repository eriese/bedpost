import {mount, shallowMount} from "@vue/test-utils"
import EncounterCalendar from "@components/widgets/EncounterCalendar.vue"


const partnerships = [{
	display: "Alice (OKC)",
	index: 0,
	partner_id: "partner_dummy1",
	_id: "partner1",
	encounters: [{
		notes: undefined,
		took_place: "2019-07-12",
		_id: "encounter1"
	},{
		notes: "some notes",
		took_place: "2019-07-15",
		_id: "encounter2"
	}]
},{
	display: "Bob (OKC)",
	index: 0,
	partner_id: "partner_dummy2",
	_id: "partner2",
	encounters: [{
		notes: "another one",
		took_place: "2019-07-11",
		_id: "encounter3"
	},{
		notes: "more notes",
		took_place: "2019-07-25",
		_id: "encounter4"
	}]
}]


const mountOptions = {
	propsData: {
		partnerships
	},
	methods: {
		$_t(key) {return key;}
	},
	mocks: {
		$screens: jest.fn()
	},
	stubs: {
		'v-select': true,
		'v-calendar': true,
		'toggle': true
	}
}

describe("Encounter calendar component", () => {
	describe("computed values", () => {
		test("selectedEncounters sorts by date descending", () => {
			const wrapper = shallowMount(EncounterCalendar, mountOptions);
			let selected = wrapper.vm.selectedEncounters;
			let selectedSorted = selected.slice().sort((a, b) => new Date(b.dates) - new Date(a.dates))
			expect(selected).toEqual(selectedSorted);
			expect(selected[0].customData.encID).toEqual("encounter4")
		})

		test("mostRecent is the month and year of the most recent encounter in selectedEncounters", () => {
			const wrapper = shallowMount(EncounterCalendar, mountOptions);
			let selected = wrapper.vm.selectedEncounters;
			let mostRecentEnc = selected[0];
			expect(mostRecentEnc.customData.encID).toEqual("encounter4");
			let mostRecentDate = mostRecentEnc.dates
			expect(wrapper.vm.mostRecent).toEqual({month: mostRecentDate.getMonth() + 1, year: mostRecentDate.getFullYear()});
		})

		test("selectedEncounters adds encounters.index.no_notes if the encounter has no notes", () => {
			const wrapper = shallowMount(EncounterCalendar, mountOptions);
			let selected = wrapper.vm.selectedEncounters;
			let noNotesEnc = selected[2];
			expect(noNotesEnc.customData.encID).toEqual("encounter1");
			expect(noNotesEnc.customData.notes).toEqual("encounters.index.no_notes");
		})
	})
})
