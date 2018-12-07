// from https://stackoverflow.com/questions/6491463/accessing-nested-javascript-objects-with-string-key?noredirect=1&lq=1
Object.getAtPath = function(o, s) {
    s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
    s = s.replace(/^\./, '');           // strip a leading dot
    let a = s.split('.');
    for (let i = 0, n = a.length; i < n; ++i) {
        let k = a[i];
        if (k in o) {
            o = o[k];
        } else {
            return;
        }
    }
    return o;
}

Object.setAtPath = function(o, s, val) {
	s = s.replace(/\[(\w+)\]/g, '.$1'); // convert indexes to properties
    s = s.replace(/^\./, '');           // strip a leading dot
    let a = s.split('.');
    for (let i = 0, n = a.length; i < n; ++i) {
    	if (typeof o != "object") {
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
        	let new_o = isNaN(parseInt(a[i+1])) ? {} : []
			o[k] = new_o;
			o = o[k]
        }
    }
}
