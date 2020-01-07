const _caret = 'M 60,80 L 35,50 L 60,20';
const _x_shape = 'M 30,30 L 70,70 M 70,30 L 30,70';
const _arrow = 'M 50,75 L 25,50 L 50,25 M75,50 L30,50';

/**
 * paths to make shapes
 *
 * @type {object}
 */
const _shapes = {
	x: _x_shape,
	arrow: _arrow,
	caret: _caret,
};

/**
 * transforms for various directions
 *
 * @type {object}
 */
const _rotations = {
	up: 'rotate(90deg)',
	down: 'rotate(270deg)',
	right: 'rotate(180deg)',
};

/**
 * Arrow Button Functional Component
 *
 * @module
 * @vue-prop {string} transform 			a transform to apply to the button svg
 * @vue-prop {string} tKey 						the translation key for the button title
 * @vue-prop {string} direction=left 			the direction the button is rotated to face. is ignored if transform is given
 * @vue-prop {object} bind 						any properties to v-bind to the button
 * @vue-prop {number} boxSize=100 		the size of the svg box. will always be square
 * @vue-prop {string} path 						an svg path to use for the button icon
 * @vue-prop {string} shape='caret' 	the shape of the button icon. is ignored if path is set. options are: caret, x, arrow
 */
export default {
	name: 'arrow-button',
	functional: true,
	props: {
		transform: String,
		tKey: String,
		direction: String,
		bind: {
			type: Object,
			default: () => {}
		},
		boxSize: {
			type: Number,
			default: 100
		},
		path: String,
		shape: {
			type: String,
			default: 'caret'
		}
	},
	render: function(createElement, {props, data, parent}) {
		// transform is given tranform or given direction.
		let transform = props.transform || _rotations[props.direction];
		// path is given path or given shape's path
		let path = props.path || _shapes[props.shape];

		// set button type and title
		data.attrs = data.attrs || {};
		data.attrs.type = data.attrs.type || 'button';
		data.attrs.title = parent.$_t(props.tKey || `helpers.arrow-button.${props.shape || 'custom'}.${props.direction || props.path ? 'custom' : 'left'}`);
		// set props to given bindings
		data.props = props.bind;
		// add base class
		data.staticClass = (data.staticClass || '') + ' cta--is-arrow';

		return createElement('button', data, [
			createElement('svg', {
				attrs: {
					viewBox: `0 0 ${props.boxSize} ${props.boxSize}`,
					focusable: false,
					style: `transform: ${transform};`,
				}
			}, [createElement('path', {
				attrs: {
					d: path,
				},
				class: ['arrow']
			})])
		]);
	}
};
