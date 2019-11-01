import {createLocalVue, mount} from "@vue/test-utils"
import TourButton from "@components/tour/TourButton.vue"


import axios from 'axios';

jest.mock('axios');

const getFalse = () => Promise.resolve({
	data: {has_tour: false}
})

const getTrue = () => Promise.resolve({
	data: {has_tour: true}
})

const getTour = () => Promise.resolve({
	data: {page_name: "page", tour_nodes: []}
})

const mountBtn = (mock) => {
	axios.get.mockClear();
	axios.get.mockImplementationOnce(mock);
	let localVue = createLocalVue();

	let btn = mount(TourButton, {localVue})
	return btn;
}

describe("TourButton component", () => {

	describe("when there is no tour for the page", () => {
		test("the button stays hidden", done => {
			let btn = mountBtn(getFalse)

			btn.vm.$nextTick(() => {
				expect(btn.isVisible()).toBe(false)
				done()
			})
		})
	})

	describe("when there is a tour for the page, but the user has seen it", () => {
		test("the button is shown", done => {
			let btn = mountBtn(getTrue)

			btn.vm.$nextTick(() => {
				expect(btn.isVisible()).toBe(true);
				done();
			})
		})

		test("clicking the button loads the tour data and emits 'tour'", done => {
			let btn = mountBtn(getTrue);

			axios.get.mockClear();
			axios.get.mockImplementationOnce(getTour);
			btn.trigger('click');

			setTimeout(() => {
				expect(axios.get).toHaveBeenCalledTimes(1);
				expect(btn.emitted()['tour']).toBeTruthy();
				done();
			})
		})
	})

	describe("when there is a tour for the page that the user has not seen", () => {
		test("the button is shown", done => {
			let btn = mountBtn(getTour)

			btn.vm.$nextTick(() => {
				expect(btn.isVisible()).toBe(true);
				done();
			})
		})

		test("the button loads the tour data and emits 'tour'", done => {
			let btn = mountBtn(getTour);

			setTimeout(() => {
				expect(axios.get).toHaveBeenCalledTimes(1);
				expect(btn.emitted()['tour']).toBeTruthy();
				done();
			})
		})
	})

	describe("when the button is clicked after the tour has already been loaded", () => {
		test("the button emits the loaded tour data", done => {
			let btn = mountBtn(getTour)

			btn.vm.$nextTick(() => {
				btn.trigger('click');
				expect(axios.get).toHaveBeenCalledTimes(1);
				expect(btn.emitted()['tour']).toBeTruthy();
				done();
			})
		})
	})
})
