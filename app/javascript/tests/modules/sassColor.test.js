import sassColors from '@modules/sassColors';

jest.mock('@stylesheets/layout/_defaults.scss', () => {
	return {
		'darkTheme-background': '#af5c87',
		'darkTheme-text': 'blue',
		'lightTheme-background': '#433060',
		'lightTheme-text': 'cornflower'
	};
});

describe('sassColors module', () => {
	it('imports styles from sass into a map of theme values nested by theme name', () => {
		expect(sassColors.darkTheme).toEqual({
			background: '#af5c87',
			text: 'blue'
		});

		expect(sassColors.lightTheme).toEqual({
			background: '#433060',
			text: 'cornflower'
		});
	});

	describe('asRgba', () => {
		describe('it returns the requested color as RGBA with the requested opacity', () => {
			afterEach(() => {
				document.body.classList.remove('dark');
			});

			it('fetches from the light theme if the theme is light', () => {
				let result = sassColors.asRgba('background', 0.5);
				expect(result).toEqual('rgba(67,48,96,0.5)');
			});

			it('fetches from the dark theme if the theme is dark', () => {
				document.body.classList.add('dark');

				let result = sassColors.asRgba('background', 0.5);
				expect(result).toEqual('rgba(175,92,135,0.5)');
			});

			it('defaults to full opacity', () => {
				let result = sassColors.asRgba('background');
				expect(result).toEqual('rgba(67,48,96,1)');
			});
		});
	});
});
