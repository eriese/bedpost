import {shallowMount, mount} from "@vue/test-utils";
import {lazyChild, lazyParent} from "@mixins/lazyCoupled";

describe("Lazy coupled mixins", () => {
	const child = {
		template: "<div/>",
		mixins: [lazyChild]
	}

	describe("With both parent and child mounted", () => {
		const parent = {
			template: "<div>{{msg}}<child/></div>",
			mixins: [lazyParent],
			data: function() {
				return {
					msg: false
				}
			},
			methods: {
				onChildMounted: function() {
					this.msg = "emitted";
				}
			}
		}

		test("The child emits lazy-child-present on the parent", () => {
			let pWrapper = mount(parent, {
				stubs: {
					child
				}
			});

			expect(pWrapper.emitted()['lazy-child-present']).toHaveLength(1);
		})

		test("The onChildMounted function of the parent is called", async () => {
			const spy = jest.spyOn(parent.methods, 'onChildMounted');

			const pWrapper = mount(parent, {
				stubs: {
					child
				}
			});

			await pWrapper.vm.$nextTick();
			expect(pWrapper.vm.msg).toBe("emitted")

			expect(spy).toHaveBeenCalled();
		})
	})
})
