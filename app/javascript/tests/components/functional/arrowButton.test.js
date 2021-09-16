import {createLocalVue, mount} from "@vue/test-utils";
import bedpostVueGlobals from "@plugins/bedpostVueGlobals";
import ArrowButton from "@components/functional/ArrowButton";

function setup(context) {
	let localVue = createLocalVue();
	localVue.use(bedpostVueGlobals);

	return mount(ArrowButton, {
		context,
		localVue
	});
}

describe("ArrowButton functional component", () => {
	test('it exists', () => {
		let wrapper = setup();
		expect(wrapper.exists()).toBe(true);
	})

	describe("rendering", () => {
		test('it is a button', () => {
			let wrapper = setup();
			expect(wrapper.element.tagName).toEqual("BUTTON");
		})
	})
})
