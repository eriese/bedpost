import arrow from '@plugins/popperModifiers/arrow';
import isModifierRequired from 'popper.js/src/utils/isModifierRequired';
import getOuterSizes from 'popper.js/src/utils/getOuterSizes';

jest.mock('popper.js/src/utils/isModifierRequired');
jest.mock('popper.js/src/utils/getOuterSizes');

isModifierRequired.mockImplementation(() => true);

const arrowElement = {
	offsetWidth: 10,
};

const outerSizes = {
	width: arrowElement.offsetWidth,
};

getOuterSizes.mockImplementation(() => outerSizes);

describe('Popper Modifier: Arrow', () => {
	describe('with no placement variation', () => {
		it('aligns the center of the arrow with the center of the reference element', () => {
			const popper = {
				offsetWidth: 30,
				contains: () => true
			};

			const reference = {
				left: 0,
				width: 40,
				right: 40,
			};

			const data = {
				placement: 'top',
				instance: {
					popper
				},
				offsets: {
					popper: {
						left: 10,
						width: popper.offsetWidth,
						right: 10 + popper.offsetWidth,
					},
					reference
				}
			};

			const options = {
				element: arrowElement
			};

			const expectedLeft = (reference.left + reference.width / 2) - arrowElement.offsetWidth / 2 - data.offsets.popper.left;

			const result = arrow(data, options);
			expect(result.offsets.arrow).toEqual({left: expectedLeft, top: ''});
		});
	});
	describe('with placement variation "start"', () => {
		const popper = {
			offsetWidth: 30,
			contains: () => true
		};

		const reference = {
			left: 20,
			width: 40,
			right: 60,
		};

		const data = {
			placement: 'top-start',
			instance: {
				popper
			},
			offsets: {
				popper: {
					left: reference.left,
					width: popper.offsetWidth,
					right: reference.left + popper.offsetWidth,
				},
				reference
			}
		};

		const options = {
			element: arrowElement
		};

		it('aligns the center of the arrow with the left side of the reference element', () => {

			const expectedLeft = reference.left + arrowElement.offsetWidth / 2 - data.offsets.popper.left;

			const result = arrow(data, options);
			expect(result.offsets.arrow.left).toEqual(expectedLeft);
		});

		it('shifts the popper element over to the left the width of the arrow element', () => {
			const expectedLeft = data.offsets.popper.left - arrowElement.offsetWidth;

			const result = arrow(data, options);
			expect(result.offsets.popper.left).toEqual(expectedLeft);
		});
	});

	describe('with placement variation "end"', () => {
		const popper = {
			offsetWidth: 30,
			contains: () => true
		};

		const reference = {
			left: 20,
			width: 40,
			right: 60,
		};

		const data = {
			placement: 'top-end',
			instance: {
				popper
			},
			offsets: {
				popper: {
					left: reference.right - popper.offsetWidth,
					width: popper.offsetWidth,
					right: reference.right,
				},
				reference
			}
		};

		const options = {
			element: arrowElement
		};

		it('aligns the center of the arrow with the right side of the reference element', () => {
			const expectedRight = reference.right - arrowElement.offsetWidth / 2 - data.offsets.popper.left;

			const result = arrow(data, options);
			expect(result.offsets.arrow.left).toEqual(expectedRight - arrowElement.offsetWidth);
		});

		it('shifts the popper element over to the right the width of the arrow element', () => {
			const expectedLeft = data.offsets.popper.left + arrowElement.offsetWidth;

			const result = arrow(data, options);
			expect(result.offsets.popper.left).toEqual(expectedLeft);
		});
	});
});
