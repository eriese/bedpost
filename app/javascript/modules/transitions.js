import {TimelineMax, TweenMax} from "gsap/TweenMax";

const slide = function(animatingOut, toLeft) {
	let dir = animatingOut ? "out" : "in";
	let container = document.getElementById(props[`${dir}Id`]);
	let tl = new TimelineMax();
	tl.set(container.parentElement, {position: "relative", overflow: "hidden", height: container.parentElement.offsetHeight})
	tl.set(container, {position: "absolute", width: container.offsetWidth, top: container.offsetTop, opacity: 1});
	let animProps = {};
	if (toLeft) {
		animProps[animatingOut && toLeft || (!animatingOut && !toLeft) ? "right" : "left"] = "100%";
	} else {
		animProps[animatingOut ? "left" : "right"] = "100%";
	}
	tl[animatingOut ? "to" : "from"](container, props.animLength, animProps);
	tl.set([container, container.parentElement], {clearProps: 'all'});
	if (!animatingOut) {
		tl.set(container, {opacity: 1});
	}
	return tl;
};

const slideLeft = function(animatingOut) {
	return slide(animatingOut, true);
}

const slideRight = function(animatingOut) {
	return slide(animatingOut, false);
}

const fade = function(animatingOut) {
	let dir = animatingOut ? "out" : "in";
	let container = document.getElementById(props[`${dir}Id`]);
	let animProps = animatingOut ? {opacity: 0} : {opacity: 1};
	return new TimelineMax().to(container, props.animLength, animProps);
};

const animationFunctions = {
	slideLeft,
	slideRight,
	fade
};

const prop_defaults = {
	animLength: 0.3,
	inProps: null,
	inId: 'page-container',
	outProps: null,
	outId: 'page-container',
	inAnimation: null,
	outAnimation: null,
	inAnimationType: null,
	outAnimationType: null,
	animationType: animationFunctions.fade
};

let props = Object.assign({}, prop_defaults);

const getTween = function(animatingOut, onComplete, onCompleteParams) {
	let dir = animatingOut ? "out" : "in";
	let anim = props[`${dir}Animation`];
	if (!anim) {
		if (props[`${dir}Props`]) {
			let container = document.getElementById(props[`${dir}Id`]);
			anim = new TimelineMax().to(container, props.animLength, props[`${dir}Props`]);
		} else if (props[`${dir}AnimationType`]) {
			anim = props[`${dir}AnimationType`];
		}
	}

	if (!anim) {
		anim = props.animationType;
	}

	if (typeof anim == "function") {
		anim = anim(animatingOut);
	}

	if (onComplete) {
		anim.eventCallback("onComplete", onComplete, onCompleteParams)
	}

	anim.play()
	props[`${dir}Animation`] = null;
}

const animIn = function() {
	getTween(false);
}

const animOut = function(visitUrl) {
	if (typeof visitUrl == "string") {
		getTween(true, Turbolinks.visit, [visitUrl])
	} else if (typeof visitUrl == "function") {
		getTween(true, visitUrl)
	} else {
		getTween(true, animIn)
	}
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

const processClickData = function(dataset) {
	dataset = dataset || {}
	for(let propName in props) {
		let given = dataset[propName]
		let granted = prop_defaults[propName]
		if (given) {
			if (propName.indexOf("Type") > 0) {
				granted = animationFunctions[given];
			} else if (propName.indexOf("Animation") > 0) {
				granted = function() {return eval(given)}
			} else {
				granted = JSON.parse(given);
			}
		}
		props[propName] = granted;
	}
}

const onTransitionTriggered = function(e) {
	let dataset = e.target.dataset;
	processClickData(dataset);
}

const addTransitionEvents = function() {
	document.addEventListener('turbolinks:before-visit', beforeUnload)

	document.addEventListener('turbolinks:click', onTransitionTriggered)
}

export {animIn, animOut, processClickData, addTransitionEvents, onTransitionTriggered};
