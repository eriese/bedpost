import {mount} from '@vue/test-utils';
import {lazyChild, lazyParent} from '@mixins/lazyCoupled';

describe('Lazy coupled mixins', () => {
	const child = {
		template: '<div class="child-component"/>',
		mixins: [lazyChild]
	};

	describe('With both parent and child mounted', () => {
		const parent = {
			template: '<div>{{msg}}<child/></div>',
			mixins: [lazyParent],
			data: function() {
				return {
					msg: false
				};
			},
			methods: {
				onChildMounted: function() {
					this.msg = 'emitted';
				}
			}
		};

		test('The child emits lazy-child-present on the parent', () => {
			let pWrapper = mount(parent, {
				stubs: {
					child
				}
			});

			expect(pWrapper.emitted()['lazy-child-present']).toHaveLength(1);
		});

		test('The onChildMounted function of the parent is called', async () => {
			const spy = jest.spyOn(parent.methods, 'onChildMounted');

			const pWrapper = mount(parent, {
				stubs: {
					child
				}
			});

			await pWrapper.vm.$nextTick();
			expect(pWrapper.vm.msg).toBe('emitted');

			expect(spy).toHaveBeenCalled();
		});
	});

	describe('a component that is a lazy parent and a lazy child', () => {
		afterEach(() => {
			jest.useRealTimers();
		});

		it('does not emit lazy-child-present until its child has emitted', async () => {
			const child = {
				template: '<div/>',
				mounted() {
					setTimeout(() => this.$parent.$emit('lazy-child-present'), 100);
				}
			};

			const middle = {
				template: '<div><child/></div>',
				mixins: [lazyParent, lazyChild],
				methods: {
					onChildMounted: jest.fn()
				},
				components: {
					'child': child
				}
			};

			const parent = {
				template: '<div><middle/></div>',
				mixins: [lazyParent],
				methods: {
					onChildMounted: jest.fn()
				},
				components: {
					'middle': middle
				}
			};

			jest.useFakeTimers();
			const wrapper = mount(parent);

			await wrapper.vm.$nextTick();
			expect(wrapper.emitted('lazy-child-present')).toBeFalsy();

			jest.runAllTimers();
			await wrapper.vm.$nextTick();
			expect(wrapper.emitted('lazy-child-present')).toBeTruthy();
		});
	});
});
