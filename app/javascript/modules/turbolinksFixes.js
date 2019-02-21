/**
 * @module  turbolinksFixes
 */

/**
 * @summary Add event listeners to fix issues with nonced inline js and turbolinks
 * @description modified from {@link https://github.com/turbolinks/turbolinks/issues/430}
 * @listens turbolinks:request-start
 * @listens turbolinks:before-cache
 */
export default function() {
	// on request start, add the current nonce to the request so that the same nonce is applied to new scripts
	document.addEventListener("turbolinks:request-start", function(event) {
		var xhr = event.data.xhr;
		xhr.setRequestHeader("X-Turbolinks-Nonce", document.getElementsByTagName("meta").namedItem("csp-nonce").content);
	});

	// before the page is cached, apply the nonce to nonced scripts in a way that allows them to work on back
	document.addEventListener("turbolinks:before-cache", function() {
		let els = document.getElementsByTagName('script');
		for (var i = 0; i < els.length; i++) {
			let el = els[i];
			if (!el.hasAttribute("nonce")) {
				continue;
			}

			el.setAttribute("nonce", el.nonce);
		}
	})
}
