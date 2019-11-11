import {mount, shallowMount} from "@vue/test-utils"
import EncounterCalendar from "@components/widgets/encounterCalendar/EncounterCalendar.vue"

global.gon = {
	partnerships: {
		partner1: {
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
		}, partner2: {
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
		}
	}
}

const mountOptions = {
	mocks: {
		$screens: jest.fn()
	},
	stubs: {
		'v-select': true,
		'v-calendar': true
	}
}

describe("Encounter calendar component", () => {
	describe("computed values", () => {
		test("mostRecent is the month and year of the most recent encounter", () => {
			const wrapper = shallowMount(EncounterCalendar, mountOptions);
			expect(wrapper.vm.mostRecent).toEqual({month: 7, year: 2019})
		})
	})

})
