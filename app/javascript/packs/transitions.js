import {TimelineMax, TweenMax} from "gsap/TweenMax"

const prop_defaults = {
	animLength: 0.2,
	animInProps: {opacity: 1},
	inId: 'page-container',
	animOutProps: {opacity: 0},
	outId: 'page-container',
	inAnimation: null,
	outAnimation: null,
}

let props = Object.assign({}, prop_defaults);

const animIn = function() {
	let inContainer = document.getElementById(props.inId)
	props.inAnimation = props.inAnimation || new TimelineMax({paused: true}).to(inContainer, props.animLength, props.animInProps);
	props.inAnimation.play();
	props.inAnimation = null;
}

const animOut = function(visitUrl) {
	let outContainer = document.getElementById(props.outId)

	props.outAnimation = props.outAnimation || new TweenMax(outContainer, props.animLength, props.animOutProps);
	if (typeof props.outAnimation == "function") {
		props.outAnimation = props.outAnimation();
	}

	props.outAnimation.eventCallback("onComplete", Turbolinks.visit, [visitUrl])

	props.outAnimation.play();
	props.outAnimation = null;
}

let no_visit = true;
const beforeUnload = function(e) {
	if (no_visit == false) {
		no_visit = true
		return;
	}

	no_visit = false;
	e.preventDefault()
	animOut(e.data.url);
}

const addTransitionEvents = function() {
	document.addEventListener('turbolinks:before-visit', beforeUnload)

	document.addEventListener('turbolinks:click', (e) => {
		let dataset = e.target.dataset
		for(let propName in props) {
			let given = dataset[propName]
			let granted = prop_defaults[propName]
			if (given) {
				if (propName.indexOf("Animation") > 0) {
					granted = function() {return eval(given)}
				} else {
					granted = JSON.parse(given);
				}
			}
			props[propName] = granted;
		}
	})
}

export {animIn, addTransitionEvents};
