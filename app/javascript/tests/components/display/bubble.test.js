import {shallowMount} from '@vue/test-utils';
import Bubble from '@components/display/Bubble.vue';

describe('Bubble component', () => {
	it('sets its height to the height of its child tippy component', () => {
		const txt = 'some text';
		const wrapper = shallowMount(Bubble, {
			propsData: {
				target: 'random',
			},
			slots: {
				default: txt
			},
			stubs: {
				tippy: {
					template: '<div><slot/></div>',
					data() {
						return {
							tip: {
								popper: {
									offsetHeight: 30
								}
							}
						};
					},
					props: {
						onMount: Function
					},
					mounted() {
						this.onMount();
					},
				},
			}
		});

		return Promise.resolve(() => {
			expect(wrapper.vm.heightVal).toEqual('30px');
		});

	});
});
