<template>
	<div @mouseover="onFocus" @mouseleave="onBlur">
		<slot v-bind="{onBlur, onFocus, vField, ariaRequired, ariaInvalid, focused}"></slot>
		<div :id="field + '-error'" class="field-errors" aria-live="assertive" aria-atomic="true" v-if="errorMsg">
			<div class="aria-only" v-html="ariaLabel"></div>
			<div v-html="errorMsg"></div>
		</div>
		<slot name="additional"></slot>
	</div>
</template>

<script>
	/**
	 * A component that wraps a form control and uses its validations to display error messages
	 * @module
	 * @vue-data {Boolean} focused=false is the component's form control focused?
	 * @vue-prop {Object} v the vuelidate object passed from the parent [VuelidateFormComponent]{@link module:components/form/VuelidateFormComponent}
	 * @vue-prop {Object} submissionError errors returned from the last submission attempt
	 * @vue-prop {String} field the name of the field this form input is for
	 * @vue-prop {String} modelName the name of the model this form is for
	 * @vue-prop {Boolean} validate does this field have validations to run?
	 * @vue-computed {?Object} vField the field's validation configuration
	 * @vue-computed {?String} [ariaLabel="Invalid: "] an additional screen-reader specific label to preceed error messages
	 * @vue-computed {Boolean} ariaInvalid should screen readers indicate that this field is invalid?
	 * @vue-computed {Boolean} ariaRequired should screen readers indicate that this field is required?
	 * @vue-computed {HTMLInputElement} the form control element for this field
	 * @vue-computed {Boolean} validity whether this field is currently valid. This doesn't take dirty state or anything besides pure validity into account
	 * @vue-computed {String} errorMsg the error message to display. chooses the first validation error and displays it
	 * @emits module:components/form/FieldErrorsComponent~input-blur with new validity value whenever validity changes
	 * @listens input.onfocus
	 * @listens input.onblur
	 */
	export default {
		name: "field_errors",
		data: function() {
			return {
				focused: false
			}
		},
		props: {
			v: Object,
			submissionError: Object,
			field: String,
			modelName: String,
			validate: Boolean
		},
		computed: {
			vField: function() {
				// no vField if this field doesn't validate
				return this.validate ? getFieldFrom(this.v.formData, this) : null
			},
			ariaLabel: function() {
				// no aria label if this field doesn't validate
				return this.validate ? this.$_t(this.$attrs["aria-label"] || "helpers.aria.invalid") : null
			},
			ariaInvalid: function() {
				// aria should only read it as invalid if it's dirty or has a submission error
				return this.vField && this.vField.$invalid &&
					(this.vField.$dirty || this.vField.submitted === false)
			},
			ariaRequired: function() {
				// aria should read it as required if it has a validation for presence
				return this.vField && this.vField.blank !== undefined;
			},
			input: function() {
				// get the input or select
				return this.$el.querySelector("input, select")
			},
			validity: function() {
				// it's valid if it doesn't have validation or is not invalid
				return !this.vField || !this.vField.$invalid;
			},
			errorMsg: function() {
				// if it's not meant to validate
				if (!this.vField ||
					// or it doesn't have errors or is untouched
					((!this.vField.$anyError || !this.vField.$dirty) &&
						// and it doesn't have a submission error
						this.vField.submitted !== false)) {
					// no message
					return "";
				}

				// if it's got a submission error
				if (this.vField.submitted === false) {
					let msg = getFieldFrom(this.submissionError, this);
					if (msg && typeof msg.join == "function") {
						msg = msg.join(this.$_t("join_delimeter"))
					}
					// return the submission error messages joined by commas
					return msg;
				}

				let field = this.field;
				let vParams = this.vField.$params
				// go through its other validations
				for (var validator in vParams) {
					// the first invalid one
					if (!this.vField[validator]) {
						// make translation interpolation arguments based on the validation type
						let params = {attribute: this.field};
						switch(validator) {
							case "too_long":
								params.count = vParams[validator].max;
								break;
							case "too_short":
								params.count = vParams[validator].min;
								break;
							case "confirmation":
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
						let trans = this.$_t(transKey, params)

						// TODO don't do this. make better translations
						if (trans.indexOf('is') == 0) {
							trans = trans.replace('is', '')
						}

						return trans;
					}
				}

				return ""
			}
		},
		watch: {
			/**
			 * Watch the validity value
			 * @param  {Boolean} newVal the new validity value
			 * @param  {Boolean} oldVal the old validity value
			 * @emits module:components/form/FieldErrorsComponent~input-blur
			 */
			validity: function (newVal, oldVal) {
				this.$emit("input-blur", this, newVal);
			}
		},
		methods: {
			/**
			 * @summary Callback for {@link event:input.onblur}
			 * @description sets the focused value and runs validation
			 */
			onBlur() {
				this.focused = false;
				this.$emit("child-blur");
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
				this.$emit("child-focus");
			},
			/**
			 * Is this field currently valid? Runs validation before returning
			 * @return {Boolean} the field's validity
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
			}
		}
	}

	/**
	 * get translation defaults for a validator's error message
	 * @param  {String} validator the type of validator
	 * @param  {String} [field]     the field being validated
	 * @param  {String} [modelName] the name of the model the field belongs to
	 * @return {String[]}           an array of translation keys to use as defaults
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
			defaults.unshift({scope: `mongoid.errors.models.${modelName}.${validator}`})
			defaults.unshift({scope: `mongoid.errors.models.${modelName}.attributes.${field}.${validator}`})
		}
		return defaults;
	}

	/**
	 * get the component's field from the given object
	 * @param  {Object} obj the object to find the field in
	 * @param  {VueComponent} vm  the component
	 * @return      the value of the field within the object
	 */
	function getFieldFrom(obj, vm) {
		// get by model name, or just field name
		return obj[vm.modelName] ? obj[vm.modelName][vm.field] : obj[vm.field]
	}

	/**
	 * An event to update the parent component on the validity of the field
	 * @event module:components/form/FieldErrorsComponent~input-blur
	 * @property {VueComponent} component the component emitting the event
	 * @property {Boolean} valid the new validity value of the emitting component's input field
	 */
</script>
