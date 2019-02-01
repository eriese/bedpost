<template>
	<div>
		<slot :scope="{onBlur, onFocus, vField, ariaRequired, ariaInvalid, focused}"></slot>
		<div :id="field + '-error'" class="field-errors" aria-live="assertive" aria-atomic="true" v-if="errorMsg">
			<div class="aria-only" v-html="ariaLabel"></div>
			<div v-html="errorMsg"></div>
		</div>
		<slot name="additional"></slot>
	</div>
</template>

<script>
	function getDefaults (validator, field, modelName) {
		let defaults = [
			{scope: `mongoid.errors.messages.${validator}`},
			{scope: `errors.attributes.${validator}`},
			{scope: `errors.messages.${validator}`}
		];

		if (modelName) {
			defaults.unshift({scope: `mongoid.errors.models.${modelName}.${validator}`})
			defaults.unshift({scope: `mongoid.errors.models.${modelName}.attributes.${field}.${validator}`})
		}
		return defaults;
	}

	function getFieldFrom(obj, vm) {
		return obj[vm.modelName] ? obj[vm.modelName][vm.field] : obj[vm.field]
	}

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
				return this.validate ? getFieldFrom(this.v.formData, this) : null
			},
			ariaLabel: function() {
				return this.validate ? I18n.t(this.$attrs["aria-label"] || "helpers.aria.invalid") : null
			},
			ariaInvalid: function() {
				return this.vField && this.vField.$invalid && this.vField.$dirty
			},
			ariaRequired: function() {
				return this.vField && this.vField.blank !== undefined;
			},
			input: function() {
				return this.$el.querySelector("input, select")
			},
			validity: function() {
				return !this.vField || !this.vField.$invalid;
			},
			errorMsg: function() {
				if (!this.validate || !this.vField ||
					((!this.vField.$anyError || !this.vField.$dirty) && this.vField.submitted !== false)) {
					return "";
				}

				if (this.vField.submitted === false) {
					let msg = getFieldFrom(this.submissionError, this);
					if (msg && typeof msg.join == "function") {
						msg = msg.join(I18n.t("join_delimeter"))
					}

					return msg;
				}

				let field = this.field;
				let vParams = this.vField.$params
				for (var validator in vParams) {
					if (!this.vField[validator]) {
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

						let defaults = getDefaults(validator, field, this.modelName);
						let transKey = defaults.shift().scope;

						params.defaults = defaults;

						let trans = I18n.t(transKey, params)
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
			validity: function (newVal, oldVal) {
				this.$emit("input-blur", this, newVal);
			}
		},
		methods: {
			onBlur() {
				this.focused = false;
				if(this.vField) {
					this.vField.$touch();
				}
			},
			onFocus() {
				this.focused = true;
			},
			isValid() {
				if(this.vField) {
					this.vField.$touch();
					return !this.vField.$invalid;
				}

				return true;
			},
			setFocus() {
				this.input.focus();
			}
		}
	}
</script>
