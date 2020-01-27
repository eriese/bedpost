import {hasGTag, sendAnalyticsEvent} from '@plugins/analytics';

/**
 * Get the dirty fields from a validation object. Recursively checks nested validation objects
 *
 * @param  {object} level the validation object
 * @return {string[]}       the names of the fields in this level and its children that were touched
 */
const getDirtyFromLevel = function(level) {
	// make an array to hold this level's dirty fields
	let dirtyFromLevel = [];
	// go through the params (these are the keys that belong to the model rather than vuelidate)
	for (var p in level.$params) {
		let child = level[p];
		// if the parameter value is not null, the parameter refers to a validator rather than a field
		if (level.$params[p] !== null || !child.$anyDirty) { continue; }


		// if the child itself is dirty, add the whole child by name
		if (child.$dirty) {
			dirtyFromLevel.push(p);
		}
		// otherwise, if the child has a dirty child
		else {
			let dirtyFromChildLevel = getDirtyFromLevel(child);
			// add only the dirty children from the child
			dirtyFromLevel.push(`${p}: (${dirtyFromChildLevel.join(',')})`);
		}
	}

	return dirtyFromLevel;
};

/**
 * Add form abandonment tracking to a form
 *
 * @param {VuelidateFormComponent} formVm the form component instance
 */
const addFormAbandonmentTracking = function(formVm) {
	// do nothing if there is no analytics or the form should be ignored
	if (!hasGTag() || formVm.$attrs['ignore-abandons'])  {return;}

	/**
	 * the event listener to apply to page unload events
	 */
	function listener () {
		// remove both listeners because depending on what cause the navigation they might not be removed when the next page loads
		window.removeEventListener('beforeunload', listener);
		document.removeEventListener('turbolinks:visit', listener);

		// don't do anything if the form submitted
		if(formVm.submitted) { return; }

		// get the dirty fields from the form
		let dirtyFields = getDirtyFromLevel(formVm.$v.formData);
		// make the fields into an event label
		let label = `Fields touched: ${dirtyFields.length > 0 ? dirtyFields.join(',') : 'none'}`;

		window.gtag('set', 'metric1', 1);
		// send the event
		sendAnalyticsEvent(formVm.name, {
			'event_category': 'form_abandonment',
			'event_label': label
		});

	}

	// add event listeners to window beforeunload and turbolinks:visit because each is called under different page-leaving conditions
	window.addEventListener('beforeunload', listener);
	document.addEventListener('turbolinks:visit', listener);
};

export default {
	data() {
		return {
			submitted: false,
		};
	},
	props: {
		analyticsEvent: Array,
		name: String
	},
	methods: {
		trackError(errorText) {
			if (this.$attrs['track-failures']) {
				sendAnalyticsEvent(this.name, {
					event_category: 'form_failure',
					event_label: errorText
				});
			}
		},
		trackSuccess() {
			this.submitted = true;
			if (this.analyticsEvent && this.analyticsEvent.length) {
				sendAnalyticsEvent.apply(this, this.analyticsEvent);
			}
		}
	},
	mounted() {
		addFormAbandonmentTracking(this);
	}
};
