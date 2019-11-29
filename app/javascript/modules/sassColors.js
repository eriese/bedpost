import sassDefaults from '@stylesheets/_defaults.scss';

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
		let whichColor = document.body.classList.contains('secondary') ? 1 : 0;
		return hex2rgba(this[key][whichColor], opacity);
	}
};

for (let k in sassDefaults) {
	let val = sassDefaults[k];

	if(k.includes('Colors') && val.includes(' ')) {
		val = val.split(' ');
	}

	sassColors[k.replace('Colors', 'Color')] = val;
}

export default sassColors;
