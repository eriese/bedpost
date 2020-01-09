import {mount} from '@vue/test-utils';
import ProgBar from '@components/display/ProgBar.vue';

describe('Progress Bar component', () => {
	describe('getPosition', () => {
		it('never exceeds 100', () => {
			const bar = mount(ProgBar, {
				propsData: {
					max: 10
				}
			});

			expect(bar.vm.getPosition(11)).toBe(100);
		});

		it('is never less than 0', () => {
			const bar = mount(ProgBar, {
				propsData: {
					min: 10
				}
			});

			expect(bar.vm.getPosition(9)).toBe(2);
		});

		describe('without log scaling', () => {
			it('returns the value as a percentage of the range', () => {
				const bar = mount(ProgBar, {
					propsData: {
						max: 10
					}
				});

				expect(bar.vm.getPosition(8)).toBe(80);
			});

			it('shifts the value based on the minimum', () => {
				const bar = mount(ProgBar, {
					propsData: {
						min: 2,
						max: 12
					}
				});

				expect(bar.vm.getPosition(10)).toBe(80);
			});
		});
		describe('with log scaling', () => {
			it('puts the given middle at the middle of the scale', () => {
				const bar1 = mount(ProgBar, {
					propsData: {
						max: 10,
						middle: 7,
						logScale: true,
					},
				});

				expect(bar1.vm.getPosition(7)).toBe(50);

				const bar2 = mount(ProgBar, {
					propsData: {
						max: 10,
						middle: 2,
						logScale: true,
					},
				});

				expect(bar2.vm.getPosition(2)).toBe(50);
			});

			it('puts the median at the middle of the scale if no middle is given', () => {
				const bar1 = mount(ProgBar, {
					propsData: {
						max: 10,
						min: 2,
						logScale: true,
					},
				});

				expect(bar1.vm.getPosition(4)).toBe(50);
			});

			it('puts the top at the end of the scale', () => {
				const bar = mount(ProgBar, {
					propsData: {
						max: 10
					}
				});

				expect(bar.vm.getPosition(10)).toBe(100);
			});

			it('puts the bottom near the start of the scale', () => {
				const bar = mount(ProgBar, {
					propsData: {
						min: 10
					}
				});

				expect(bar.vm.getPosition(10)).toBe(2);
			});
		});
	});

	describe('benchmarkStyle', () => {
		it('is display: none if no benchmark is given', () => {
			const bar = mount(ProgBar, {});

			expect(bar.vm.benchmarkStyle).toEqual({display: 'none'});
		});

		it('is left: position if a ben is given', () => {
			const bar = mount(ProgBar, {
				propsData: {
					benchmark: 1,
					max: 10
				}
			});

			expect(bar.vm.benchmarkStyle).toEqual({left: '10%'});
		});
	});
});
