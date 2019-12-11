import {mount, createLocalVue} from '@vue/test-utils';
import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import HiddenRadio from '@components/form/encounter/HiddenRadio.vue';

function setupLocalVue() {
	const localVue = createLocalVue();
	localVue.use(bedpostVueGlobals);
	return localVue;
}
describe('Hidden Radio Component', () => {
	const parent = {
		template: '<div><hidden-radio v-model="value" label="label" :input-value="true"/></div>',
		components: {HiddenRadio},
		data() {
			return {
				value: false
			};
		},
	};

	it ('emits a change event when checked', () => {
		const wrapper = mount(parent, {localVue: setupLocalVue()});
		const radio = wrapper.find(HiddenRadio);
		radio.find('input').setChecked(true);
		expect(radio.emitted('change')).toBeTruthy();
	});

	describe('setChecked', () => {
		it('is called on mount', () => {
			const setChecked = jest.fn();
			const wrapper = mount(HiddenRadio, {
				localVue: setupLocalVue(),
				methods: {
					setChecked
				}
			});

			expect(setChecked).toHaveBeenCalled();
		});

		it('is called on update', () => {
			const setChecked = jest.fn();
			const wrapper = mount(HiddenRadio, {
				localVue: setupLocalVue(),
				methods: {
					setChecked
				}
			});

			setChecked.mockClear();

			wrapper.setProps({baseName: 'base'});
			expect(setChecked).toHaveBeenCalled();
		});

		it('checks the input if the values match', () => {
			const wrapper = mount(HiddenRadio, {
				localVue: setupLocalVue(),
				propsData: {
					checked: 'something',
					inputValue: 'val'
				}
			});
			const input = wrapper.vm.$refs.input;

			expect(input.checked).toBe(false);

			const spy = jest.spyOn(wrapper.vm, 'setChecked');
			wrapper.setProps({
				checked: 'val',
			});
			expect(spy).toHaveBeenCalled();
			expect(input.checked).toBe(true);
		});

		it('un-checks the input if the values do not match', () => {
			const wrapper = mount(HiddenRadio, {
				localVue: setupLocalVue(),
				propsData: {
					checked: 'val',
					inputValue: 'val'
				}
			});
			const input = wrapper.vm.$refs.input;

			expect(input.checked).toBe(true);

			const spy = jest.spyOn(wrapper.vm, 'setChecked');
			wrapper.setProps({
				checked: 'something',
			});
			expect(spy).toHaveBeenCalled();
			expect(input.checked).toBe(false);
		});
	});
});
