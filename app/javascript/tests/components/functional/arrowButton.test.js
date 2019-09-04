import {createLocalVue, mount, shallowMount} from "@vue/test-utils";
import bedpostVueGlobals from "@plugins/bedpostVueGlobals";
import ArrowButton from "@components/functional/ArrowButton";

async function setup(context) {
	let localVue = createLocalVue();
	await bedpostVueGlobals(localVue);

	return shallowMount(ArrowButton, {
		context,
		localVue
	});
}

describe("ArrowButton functional component", () => {
	test('it exists', async () => {
		let wrapper = await setup();
		expect(wrapper.exists()).toBe(true);
	})

	describe("rendering", () => {
		test('it is a button', async () => {
			let wrapper = await setup();
			expect(wrapper.is("button")).toBeTruthy();
		})
	})
})
