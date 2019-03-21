const _caret = "M 70,90 L 30,50 L 70,10"
const _x_shape = "M 20,20 L 80,80 M 80,20 L 20,80"

export default {
	name: "arrow-button",
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
		path: String
	},
	render(createElement, {props, data, parent}) {
		let transform = props.transform
		let path = props.path || props.direction == "x" ? _x_shape : _caret

		if (!transform) {
			switch(props.direction) {
				case "up":
				transform = "translate(100,0) rotate(90)"
				break;
				case "down":
				transform = "translate(0,95) rotate(270)"
				break;
				case "right":
				transform = "translate(100, 100) rotate(180)"
				break;
			}
		}

		data.attrs.type = data.attrs.type || "button"
		data.attrs.title = parent.$root.t(props.tKey)
		data.props = props.bind
		data.staticClass = (data.staticClass || "") + " arrow-button"

		return createElement("button", data, [
			createElement("svg", {
				attrs: {
					viewBox: `0 0 ${props.boxSize} ${props.boxSize}`,
					focusable: false
				}
			}, [createElement("path", {
				attrs: {
					d: path,
					transform: transform
				},
				class: ["arrow"]
			})])
		])
	}
}
