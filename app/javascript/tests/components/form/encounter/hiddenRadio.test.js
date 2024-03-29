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
		const radio = wrapper.getComponent(HiddenRadio);
		radio.find('input').setChecked(true);
		expect(radio.emitted('change')).toBeTruthy();
	});

	describe('setChecked', () => {
		it('is called on mount', () => {
			const setChecked = jest.fn();
			const cleanSpec = {...HiddenRadio};
			cleanSpec.methods = {...cleanSpec.methods, setChecked};
			const wrapper = mount(cleanSpec, {
				localVue: setupLocalVue()
			});

			expect(setChecked).toHaveBeenCalled();
		});

		it('is called on update', async() => {
			const setChecked = jest.fn();
			const cleanSpec = {...HiddenRadio};
			cleanSpec.methods = {...cleanSpec.methods, setChecked};

			const wrapper = mount(cleanSpec, {
				localVue: setupLocalVue()
			});

			setChecked.mockClear();

			wrapper.setProps({baseName: 'base'});
			await wrapper.vm.$nextTick();
			expect(setChecked).toHaveBeenCalled();
		});

		it('checks the input if the values match', async() => {
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

			await wrapper.vm.$nextTick();
			expect(spy).toHaveBeenCalled();
			expect(input.checked).toBe(true);
		});

		it('un-checks the input if the values do not match', async() => {
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
			await wrapper.vm.$nextTick();
			expect(spy).toHaveBeenCalled();
			expect(input.checked).toBe(false);
		});
	});
});
