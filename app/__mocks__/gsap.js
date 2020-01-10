const gsapModule = jest.requireActual('gsap');
const gsapSet = gsapModule.gsap.set;

function isDefinedExecute(callback, context = null, args = []) {
	let isDefined = (val) => {
		return val !== undefined && val !== null;
	};
	let isFunction = (obj) => {
		return !!(obj && obj.constructor && obj.call && obj.apply);
	};

	if (isDefined(callback) && isFunction(callback)) {
		return callback.apply(context, args);
	} else {
		return false;
	}
}

export const gsap = {
	...gsapModule.gsap,
	to: (el, duration, options) => {
		isDefinedExecute(options.onStart, options.callbackScope || this, options.onStartParams);
		delete options.onStart;
		setTimeout(() => {
			gsapSet(el, options);
		}, duration);
	}
};
