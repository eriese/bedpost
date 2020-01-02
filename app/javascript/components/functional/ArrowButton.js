const _caret = 'M 60,80 L 35,50 L 60,20';
const _x_shape = 'M 30,30 L 70,70 M 70,30 L 30,70';
const _arrow = 'M 50,75 L 25,50 L 50,25 M75,50 L30,50';

const _shapes = {
	x: _x_shape,
	arrow: _arrow,
	caret: _caret,
};

const _rotations = {
	up: 'rotate(90)',
	down: 'rotate(270)',
	right: 'rotaate(180)',
};

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
		let transform = props.transform || _rotations[props.direction];
		let path = props.path || _shapes[props.shape];

		data.attrs = data.attrs || {};
		data.attrs.type = data.attrs.type || 'button';
		data.attrs.title = parent.$_t(props.tKey);
		data.props = props.bind;
		data.staticClass = (data.staticClass || '') + ' cta--is-arrow';

		return createElement('button', data, [
			createElement('svg', {
				attrs: {
					viewBox: `0 0 ${props.boxSize} ${props.boxSize}`,
					focusable: false,
					transform: transform,
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
