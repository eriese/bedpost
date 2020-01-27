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
		expect(wrapper.contains(TippyComponent)).toBe(true);
	});

	it('uses an aside to replace the tippy component if it is meant to show always', () => {
		const wrapper = mount(Tooltip, {
			propsData: {
				showAlways: true
			}
		});

		expect(wrapper.contains('aside.tippy-popper')).toBe(true);
		expect(wrapper.contains(TippyComponent)).toBe(false);
	});

	describe('theme', () => {
		it('adds a theme to the TippyComponent', () => {
			const wrapper = mount(Tooltip);

			wrapper.find(TippyComponent).setProps({visible: true});

			expect(wrapper.contains(`.tippy-tooltip.${wrapper.vm.theme}-theme`)).toBe(true);
		});

		it('adds a theme to the aside', () => {
			const wrapper = mount(Tooltip, {
				propsData: {
					showAlways: true
				}
			});

			expect(wrapper.contains(`.tippy-tooltip.${wrapper.vm.theme}-theme`)).toBe(true);
		});
	});

	describe('fieldFocused watcher', () => {
		beforeAll(() => {
			jest.useFakeTimers();
		});
		afterAll(() => {
			jest.useRealTimers();
		});

		it('sets a timeout to delay showing or hiding the tooltip when fieldFocused == true', () => {
			const wrapper = mount(Tooltip, {
				propsData: {
					useScope: {focused: false, hovered: false}
				}
			});

			wrapper.setProps({
				useScope: {focused: true, hovered: false}
			});

			expect(wrapper.vm.tippyProps.visible).toBe(false);
			jest.runAllTimers();

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
