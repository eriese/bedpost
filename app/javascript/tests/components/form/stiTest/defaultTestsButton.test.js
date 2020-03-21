/* global global:writable */
import { mount, createLocalVue } from '@vue/test-utils';
import DefaultTestsButton from '@components/form/stiTest/DefaultTestsButton.vue';

describe('Default Test Button Component', () => {
	global.gon = {
		diagnoses: [{
			_id: 'hsv',
			category: ['cat1', 'cat2']
		}, {
			_id: 'hpv',
			category: ['cat1', 'default']
		},{
			_id: 'hiv',
			category: ['cat2', 'default']
		}]
	};

	const parentComponent = {
		template: '<div><default-tests-button @populate="onPopulate" v-model="valueList" :category="category"></default-tests-button></div>',
		components: {
			'default-tests-button': DefaultTestsButton
		},
		data() {
			return {
				valueList: this.list.slice()
			};
		},
		props: {
			list: Array,
			category: {
				type: String,
				default: 'default'
			}
		},
		methods: {
			onPopulate(el) {
				this.valueList.push(el);
			}
		}
	};

	describe('populateDefaults', () => {
		function mountWrapper(startingList) {
			const localVue = createLocalVue();
			localVue.mixin({
				methods: {
					$_t: jest.fn()
				}
			});

			const parentWrapper = mount(parentComponent, {
				propsData: {
					list: startingList
				},
				localVue
			});

			const button = parentWrapper.find(DefaultTestsButton);

			return {parentWrapper, button};
		}

		it('overwrites empty entries in the list', () => {
			const list = [{tested_for_id: null}];
			const {parentWrapper, button} = mountWrapper(list);

			button.vm.populateDefaults();

			expect(parentWrapper.vm.valueList).toHaveLength(2);
			expect(parentWrapper.vm.valueList[0].tested_for_id).toEqual('hpv');
			expect(parentWrapper.vm.valueList[1].tested_for_id).toEqual('hiv');
		});

		it('leaves already selected non-applicable stis in the list', () => {
			const list = [{tested_for_id: 'hsv'}];
			const {parentWrapper, button} = mountWrapper(list);

			button.vm.populateDefaults();
			expect(parentWrapper.vm.valueList).toHaveLength(3);
			expect(parentWrapper.vm.valueList[0].tested_for_id).toEqual('hsv');
			expect(parentWrapper.vm.valueList[1].tested_for_id).toEqual('hpv');
			expect(parentWrapper.vm.valueList[2].tested_for_id).toEqual('hiv');
		});

		it('does not duplicate entries', () => {
			const list = [{tested_for_id: 'hiv'}];
			const {parentWrapper, button} = mountWrapper(list);

			button.vm.populateDefaults();

			expect(parentWrapper.vm.valueList).toHaveLength(2);
			expect(parentWrapper.vm.valueList[0].tested_for_id).toEqual('hiv');
			expect(parentWrapper.vm.valueList[1].tested_for_id).toEqual('hpv');
		});
	});
});
