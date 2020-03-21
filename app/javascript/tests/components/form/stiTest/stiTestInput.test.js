import {shallowMount} from '@vue/test-utils';
import StiTestInput from '@components/form/stiTest/StiTestInput.vue';

describe('Sti Test Input Component', () => {
	describe('availableDiagnoses', () => {
		global.gon = {
			diagnoses: [{
				_id: 'hsv'
			}, {
				_id: 'hpv'
			}, {
				_id: 'hiv'
			}]
		};

		function mountInput() {
			const input = shallowMount(StiTestInput, {
				propsData: {
					value: {
						tested_for: undefined,
						tested_on: new Date(),
						positive: false
					},
					state: {
						baseName: 'baseName'
					},
					tracker: undefined,
				},
				methods: {
					$_t: (key, options) => {
						return {key, options};
					}
				},
				stubs: {
					'hidden-radio': true,
					'v-select': true
				}
			});

			const trackerFactory = input.emitted('start-tracking')[0][0];
			const tracker = trackerFactory({tests_for: []});
			input.setProps({tracker});

			return {input, tracker};
		}

		it('returns all options if nothing is selected', () => {
			const {input} = mountInput();
			expect(input.vm.availableDiagnoses).toHaveLength(3);
		});

		it('does not include options that have been selected by another input', () => {
			const {input, tracker} = mountInput();
			tracker.update([{tested_for: 'hpv'}]);

			const actual = input.vm.availableDiagnoses;
			expect(actual).toHaveLength(2);
			expect(actual).not.toContain(expect.objectContaining({value: 'hpv'}));
		});

		it('maps diagnoses to objects with label and value', () => {
			const {input} = mountInput();

			const actual = input.vm.availableDiagnoses;
			const expected = {
				label: input.vm.$_t('hpv', {scope: 'diagnosis.name_formal'}),
				value: 'hpv'
			};
			expect(actual).toContainEqual(expected);
		});
	});
});
