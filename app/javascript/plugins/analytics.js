export const hasGTag = () => typeof window.gtag == 'function';
export const sendAnalyticsEvent = function (actionName, options) {
	if (!hasGTag()) {return;}

	console.log(actionName, options);
	window.gtag('event', actionName, options);
};

const getDirtyFromLevel = function(level) {
	let dirtyFromLevel = [];
	for (var p in level.$params) {
		let child = level[p];
		if (level.$params[p] !== null || !child.$anyDirty) { continue; }


		if (child.$dirty) {
			dirtyFromLevel.push(p);
		}else if (child.$anyDirty && !child.$dirty) {
			let dirtyFromChildLevel = getDirtyFromLevel(child);
			dirtyFromLevel.push(`${p}: (${dirtyFromChildLevel.join(',')})`);
		}
	}

	return dirtyFromLevel;
};

const getFormDirty = function(formVm) {
	let dirtyFields = [], $v = formVm.$v;
	if ($v.$anyDirty) {
		dirtyFields = getDirtyFromLevel($v.formData);
	}
	return dirtyFields;
};

export const addFormAbandonmentTracking = function(formVm) {
	if (!hasGTag() || formVm.$attrs['ignore-abandons'])  {return;}

	function listener () {
		window.removeEventListener('beforeunload', listener);
		document.removeEventListener('turbolinks:visit', listener);

		if(!formVm.submitted) {
			let dirtyFields = getFormDirty(formVm);
			let label = `Fields touched: ${dirtyFields.length > 0 ? dirtyFields.join(',') : 'none'}`;
			sendAnalyticsEvent(formVm.name, {
				'event_category': 'form_abandonment',
				'event_label': label
			});
		}
	}

	window.addEventListener('beforeunload', listener);

	document.addEventListener('turbolinks:visit', listener);
};

export default {
	install(Vue) {
		Vue.mixin({
			methods: {
				sendAnalyticsEvent
			}
		});
	}
};
