import {mount} from '@vue/test-utils';
import Tooltip from '@components/form/Tooltip.vue';
import {TippyComponent} from 'vue-tippy';

global.document.createRange = () => ({
	setStart: () => {},
	setEnd: () => {},
	commonAncestorContainer: {
		nodeName: 'BODY',
		ownerDocument: document,
	},
});

describe('Tooltip component', () => {
	it('uses a tippy component by default', () => {
		const wrapper = mount(Tooltip);

		expect(wrapper.findComponent(TippyComponent)).not.toBeUndefined();
	});

	it('uses an aside to replace the tippy component if it is meant to show always', () => {
		const wrapper = mount(Tooltip, {
			propsData: {
				showAlways: true
			}
		});

		expect(wrapper.find('aside.tippy-popper').exists()).toBeTruthy();
		expect(wrapper.findComponent(TippyComponent).exists()).toBeFalsy();
	});

	describe('theme', () => {
		it('adds a theme to the TippyComponent', () => {
			const wrapper = mount(Tooltip);

			expect(wrapper.find(`.tippy-tooltip.${wrapper.vm.theme}-theme`)).not.toBeUndefined();
		});

		it('adds a theme to the aside', () => {
			const wrapper = mount(Tooltip, {
				propsData: {
					showAlways: true
				}
			});

			expect(wrapper.find(`.tippy-tooltip.${wrapper.vm.theme}-theme`)).not.toBeUndefined();
		});
	});

	describe('fieldFocused watcher', () => {
		beforeAll(() => {
			jest.useFakeTimers();
		});
		afterAll(() => {
			jest.useRealTimers();
		});

		it('sets a timeout to delay showing or hiding the tooltip when fieldFocused == true', async () => {
			const wrapper = mount(Tooltip, {
				propsData: {
					useScope: {focused: false, hovered: false}
				}
			});

			wrapper.setProps({
				useScope: {focused: true, hovered: false}
			});

			await wrapper.vm.$nextTick();
			expect(wrapper.vm.tippyProps.visible).toBe(false);
			jest.runAllTimers();
			await wrapper.vm.$nextTick();
			expect(wrapper.vm.tippyProps.visible).toBe(true);
		});

		it('cancels the running timer if the value changes before the tooltip showed/hid', () => {
			const wrapper = mount(Tooltip, {
				propsData: {
					useScope: {focused: false, hovered: false}
				}
			});

			wrapper.setProps({
				useScope: {focused: true, hovered: false}
			});

			jest.advanceTimersByTime(50);

			wrapper.setProps({
				useScope: {focused: false, hovered: false}
			});

			jest.runAllTimers();

			expect(wrapper.vm.tippyProps.visible).toBe(false);
		});
	});

	describe('with scope', () => {
		it('sets a manual trigger', () => {
			const scope = {
				focused: false,
				hovered: false,
			};

			const wrapper = mount(Tooltip, {
				propsData: {
					useScope: scope
				}
			});

			expect(wrapper.vm.tippyProps.trigger).toEqual('manual');
		});
	});
});
