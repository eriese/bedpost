import sassDefaults from '@stylesheets/layout/_defaults.scss';

/**
 * Convert a hex color to an rgba value
 *
 * @param  {string} hex     	a hexadecimal color
 * @param  {number} [opacity=1] the opacity for the color
 * @return {string}         	the color represented as rgba
 */
function hex2rgba(hex, opacity){
	if (opacity === undefined) opacity = 1;
	hex = hex.replace('#','');
	let r = parseInt(hex.substring(0, hex.length/3), 16);
	let g = parseInt(hex.substring(hex.length/3, 2*hex.length/3), 16);
	let b = parseInt(hex.substring(2*hex.length/3, 3*hex.length/3), 16);

	return `rgba(${r},${g},${b},${opacity})`;
}

const sassColors = {
	asRgba(key, opacity) {
		opacity = opacity === undefined ? 1 : opacity;
		let whichColor = document.body.classList.contains('dark') ? 'darkTheme' : 'lightTheme';
		return hex2rgba(this[whichColor][key], opacity);
	}
};

for (let k in sassDefaults) {
	let keySplit = k.split('-');
	let key = keySplit.shift();
	sassColors[key] = sassColors[key] || {};
	sassColors[key][keySplit.join('-')] = sassDefaults[k];
}

export default sassColors;
