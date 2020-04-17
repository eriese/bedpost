// from https://stackoverflow.com/questions/6491463/accessing-nested-javascript-objects-with-string-key?noredirect=1&lq=1
Object.getAtPath = function(o, s) {
	if (!o || !s || typeof o != 'object') {
		return;
	}

	s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
	s = s.replace(/^\./, '');           // strip a leading dot
	let a = s.split('.');
	for (let i = 0, n = a.length; i < n; ++i) {
		let k = a[i];
		if (o !== undefined && k in o) {
			o = o[k];
		} else {
			return;
		}
	}
	return o;
};

Object.setAtPath = function(o, s, val) {
	s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
	s = s.replace(/^\./, '');           // strip a leading dot
	let a = s.split('.');
	for (let i = 0, n = a.length; i < n; ++i) {
		if (typeof o != 'object') {
			return false;
		}

		let k = a[i];

		// if it's the last part of the path, set and return true
		if (i == n - 1){
			o[k] = val;
			return true;
		}

		if (k in o) {
			o = o[k];
		} else {
			// if nothing exists at that path, add the right type of object
			let new_o = isNaN(parseInt(a[i+1])) ? {} : [];
			o[k] = new_o;
			o = o[k];
		}
	}
};

Array.prototype.findLastIndex = function(predicate) {
	let index = this.slice().reverse().findIndex(predicate);
	let len = this.length - 1;
	return index >= 0 ? len - index : index;
};

Array.move = function(arr, old_index, new_index) {
	while (old_index < 0) {
		old_index += arr.length;
	}
	while (new_index < 0) {
		new_index += arr.length;
	}
	if (new_index >= arr.length) {
		var k = new_index - arr.length + 1;
		while (k--) {
			arr.push(undefined);
		}
	}
	arr.splice(new_index, 0, arr.splice(old_index, 1)[0]);
	return arr; // for testing purposes
};

window.Utils = {
	getBoundingDocumentRect: function(elem, noOffset) {
		let rect = elem.getBoundingClientRect();
		let scrollX = noOffset ? 0 : window.pageXOffset;
		let scrollY = noOffset ? 0 : window.pageYOffset;
		let calc = {
			scrollX: noOffset ? window.pageXOffset : scrollX,
			scrollY: noOffset ? window.pageYOffset : scrollY,
			x: rect.x + scrollX,
			y: rect.y + scrollY,
			width: rect.width || elem.offsetWidth,
			height: rect.height || elem.offsetHeight,
			top: rect.top + scrollY,
			bottom: rect.bottom + scrollY,
			left: rect.left + scrollX,
			right: rect.right + scrollX,
		};

		calc.centerX = calc.left + calc.width / 2;
		calc.centerY = calc.top + calc.height / 2;

		return calc;
	},
	isTouchDevice: function() {
		return (('ontouchstart' in window)
			|| (navigator.MaxTouchPoints > 0)
			|| (navigator.msMaxTouchPoints > 0));
	},
};
