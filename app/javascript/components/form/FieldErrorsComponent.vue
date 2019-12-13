<template>
	<div @mouseover="onHover(true)" @mouseleave="onHover(false)">
		<slot v-bind="slotScope"></slot>
		<div :id="field + '-error'" class="field-errors" aria-live="assertive" aria-atomic="true" v-if="errorMsg">
			<div class="aria-only" v-html="$_t('helpers.aria.invalid')"></div>
			<div v-html="errorMsg"></div>
		</div>
		<slot name="additional"></slot>
	</div>
</template>

<script>
import inputSlot from '@mixins/inputSlot';
import {lazyChild} from '@mixins/lazyCoupled';
/**
 * A component that wraps a form control and uses its validations to display error messages. Works best with parent [VuelidateFormComponent]{@link module:components/form/VuelidateFormComponent}
 *
 * @module
 * @vue-data {boolean} focused=false is the component's form control focused?
 * @vue-data {boolean} hovered=false is the component's form control being hovered over?
 * @vue-data {HTMLElement} input=null the element of the slotted form control
 * @vue-prop {object} vField the vuelidate validations for this field object passed from the parent
 * @vue-prop {object} submissionError errors for this field returned from the last submission attempt
 * @vue-prop {string} modelName the name of the model this form is for
 * @vue-computed {string} field the name of the field this form input is for
 * @vue-prop {boolean} validate does this field have validations to run?
 * @vue-computed {boolean} validity whether this field is currently valid. This doesn't take dirty state or anything besides pure validity into account
 * @vue-computed {string} errorMsg the error message to display. chooses the first validation error and displays it
 * @mixes inputSlot
 * @emits module:components/form/FieldErrorsComponent~input-blur with new validity value whenever validity changes
 * @listens input.onfocus
 * @listens input.onblur
 */
export default {
	name: 'field_errors',
	mixins: [inputSlot, lazyChild],
	data: function() {
		return {
			focused: false,
			hovered: false,
			input: null,
		};
	},
	props: {
		vField: Object,
		submissionError: Array,
		isDate: Boolean,
		modelName: String,
	},
	computed: {
		field() {
			let expression = this.$vnode.data.model.expression.split('.');
			return expression[expression.length - 1];
		},
		validity: function() {
			// it's valid if it doesn't have validation or is not invalid
			return !this.vField || !this.vField.$invalid;
		},
		slotScope() {
			return {
				...this.inputSlotScope,
				onBlur: this.onBlur,
				onFocus: this.onFocus,
				ariaRequired: this.vField && this.vField.blank !== undefined,
				ariaInvalid: this.vField && this.vField.$invalid && (this.vField.$dirty || this.vField.submitted === false),
				focused: this.focused || this.hovered,
			};
		},
		errorMsg: function() {
			// if it's not meant to validate
			if (!this.vField ||
				// or it doesn't have errors or is untouched
				((!this.vField.$anyError || !this.vField.$dirty) &&
					// and it doesn't have a submission error
					this.vField.submitted !== false)) {
				// no message
				return '';
			}

			// if it's got a submission error
			if (this.vField.submitted === false) {
				let msg = this.submissionError;
				if (msg && typeof msg.join == 'function') {
					msg = msg.join(this.$_t('join_delimeter'));
				}
				// return the submission error messages joined by commas
				return msg;
			}

			let field = this.field;
			let vParams = this.vField.$params;
			// go through its other validations
			for (var validator in vParams) {
				// the first invalid one
				if (!this.vField[validator]) {

					if(vParams[validator].responseMessage) {
						let messages = vParams[validator].responseMessage.message;
						return messages.join ? messages.join(this.$_t('join_delimeter')) : messages;
					}
					// make translation interpolation arguments based on the validation type
					let params = {attribute: this.field};
					switch(validator) {
					case 'too_long':
						params.count = vParams[validator].max;
						break;
					case 'too_short':
						params.count = vParams[validator].min;
						break;
					case 'confirmation':
						params.attribute = vParams[validator].eq;
						break;
					}

					// get the translation cascades
					let defaults = getDefaults(validator, field, this.modelName);
					// get the first key
					let transKey = defaults.shift().scope;
					// add the defaults to the params
					params.defaults = defaults;

					//translate it
					let trans = this.$_t(transKey, params);

					// TODO don't do this. make better translations
					if (trans.indexOf('is') == 0) {
						trans = trans.replace('is', '');
					}

					return trans;
				}
			}

			return '';
		}
	},
	watch: {
		/**
		 * Watch the validity value
		 *
		 * @param  {boolean} newVal the new validity value
		 * @emits module:components/form/FieldErrorsComponent~input-blur
		 */
		validity: function (newVal) {
			this.$emit('input-blur', this, newVal);
		}
	},
	methods: {
		/**
		 * @summary Callback for {@link event:input.onblur}
		 * @description sets the focused value and runs validation
		 */
		onBlur() {
			this.focused = false;
			this.$emit('child-blur');
			if(this.vField) {
				this.vField.$touch();
			}
		},
		/**
		 * @summary Callback for {@link event:input.onfocus}
		 * @description sets the focused value
		 */
		onFocus() {
			this.focused = true;
			this.$emit('child-focus');
		},
		/**
		 * Is this field currently valid? Runs validation before returning
		 *
		 * @return {boolean} the field's validity
		 */
		isValid() {
			if(this.vField) {
				this.vField.$touch();
				return !this.vField.$invalid;
			}

			return true;
		},
		/**
		 * Focus the input element
		 */
		setFocus() {
			this.input.focus();
		},
		/**
		 * Callback for mousein and mouseout events
		 * @param  {boolean} isHovered is the mouse in?
		 */
		onHover(isHovered) {
			this.hovered = isHovered;
		}
	},
	mounted() {
		// get the input
		this.input = this.$el.querySelector('input, select');
		// if this is a date, convert the value to a date object
		if (this.isDate) {
			this.model = this.model ? new Date(this.model) : new Date();
		}
	},
};

/**
 * get translation defaults for a validator's error message
 *
 * @param  {string} validator the type of validator
 * @param  {string} [field]     the field being validated
 * @param  {string} [modelName] the name of the model the field belongs to
 * @return {string[]}           an array of translation keys to use as defaults
 */
function getDefaults (validator, field, modelName) {
	// start with defaults pertaining to the validator
	let defaults = [
		{scope: `mongoid.errors.messages.${validator}`},
		{scope: `errors.attributes.${validator}`},
		{scope: `errors.messages.${validator}`}
	];

	// if there's a modelName given, add model and field keys at the beginning
	if (modelName) {
		defaults.unshift({scope: `mongoid.errors.models.${modelName}.${validator}`});
		defaults.unshift({scope: `mongoid.errors.models.${modelName}.attributes.${field}.${validator}`});
	}
	return defaults;
}

/**
 * An event to update the parent component on the validity of the field
 *
 * @event module:components/form/FieldErrorsComponent~input-blur
 * @property {VueComponent} component the component emitting the event
 * @property {boolean} valid the new validity value of the emitting component's input field
 */
</script>
