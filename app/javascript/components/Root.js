import {animIn} from '@modules/transitions';
import tourRoot from '@mixins/tourRoot';

/**
 * The root Vue instance for the application
 * @module
 * @vue-data {Object} [confirmations={}] an object tracking the confirmation state of confirmable actions on the page
 * @mixes tourRoot
 */
export default {
	el: '#vue-container',
	mounted: animIn,
	mixins: [tourRoot],
	data: function() {
		// get anything with a data-confirm to add to confirmations
		let confirmations = {};
		let confNodes = document.querySelectorAll("[data-confirm]");
		for (let i = 0; i < confNodes.length; i++) {
			let node = confNodes[i];
			confirmations[node.id] = null;
		}

		return {confirmations, additional: {}}
	},
	methods: {
		t: function(scope, options) {
			return this.$_t(scope, options)
		},
		/**
		 * Is the element's purpose confirmed?
		 * @param  {String}  message the confirmation message to show
		 * @param  {HTMLElement}  element the element whose action requires confirmation
		 * @return {Boolean}         whether the action is confirmed
		 */
		isConfirmed: function(message, element) {
			let id = element.id;
			// if there's already a message showing for this element's id, this is the second try, so it's confirmed
			if (this.confirmations[id]) {
				this.cancelConfirm(id);
				return true;
			}

			// otherwise set the message to show and return false
			this.confirmations[id] = message;
			return false;
		},
		/**
		 * Cancel a confirmation
		 * @param  {String} confirmId the id of the element whose confirmation is being canceled
		 */
		cancelConfirm: function(confirmId) {
			// set it back to null
			this.confirmations[confirmId] = null;
		},
		/**
		 * Add an additional field to the additional object (basically a junk drawer)
		 * @param {[String]} fieldName the name of the field
		 * @param value     the value of the field
		 */
		additionalField: function(fieldName, value) {
			this.$set(this.additional, fieldName, value)
		}
	}
}
