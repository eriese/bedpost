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
