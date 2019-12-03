import {shallowMount} from '@vue/test-utils';
import DynamicFieldList from '@components/form/DynamicFieldList.vue';
import gsap from 'gsap';

jest.mock('gsap');
gsap.to.mockImplementation((el, duration, options) => {
	if(options.onComplete) {
		options.onComplete.apply(undefined, options.onCompleteParams);
	}
});

describe('Dynamic Field List Component', () => {
	global.gon = {
		dummy: {}
	};

	const childStub = {
		template: '<div/>',
		methods: {
			blur: jest.fn()
		}
	};

	function mountList(list) {
		return shallowMount(DynamicFieldList, {
			propsData: {
				list,
				componentType: 'encounter-contact-field',
				baseName: 'encounter[contacts_attributes]'
			},
			stubs: {
				'encounter-contact-field': childStub,
				'arrow-button': true
			}
		});
	}
	it('mounts with an empty list', async() => {
		let dfl = mountList([]);
		expect(dfl.exists()).toBe(true);
	});

	describe('removeFromList', () => {
		it('reduces the number of list items being submitted', () => {
			const dfl = mountList([{name: 'one'}, {name: 'two'}]);

			dfl.vm.removeFromList(0);
			expect(dfl.vm.numSubmitting).toBe(1);
		});

		it('marks the deleted item for _destroy', () => {
			const list = [{name: 'one'}, {name: 'two'}];
			const dfl = mountList(list);

			const deleted = list[0];
			dfl.vm.removeFromList(0);
			expect(deleted._destroy).toBe(true);
		});

		it('updates the position on subsequent items', () => {
			const list = [{name: 'one'}, {name: 'two'}, {name: 'three'}];
			const dfl = mountList(list);
			const secondPos = list[1].position;

			dfl.vm.removeFromList(1);
			expect(list[2].position).toBe(secondPos);
		});
	});
});
