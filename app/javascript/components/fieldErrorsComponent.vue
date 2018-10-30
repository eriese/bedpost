<template>
	<div class="field-errors" v-if="errorMsg" v-html="errorMsg"></div>
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
			return {}
		},
		props: {
			v: Object,
			submissionError: Object,
			field: String,
			modelName: String
		},
		computed: {
			vField: function() {
				return getFieldFrom(this.v.formData, this)
			},
			errorMsg: function() {
				if (!this.vField.$dirty || !this.vField.$anyError) {
					return "";
				}

				if (!this.vField.submitted) {
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
						let params = {};
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

						return I18n.t(transKey, params)
					}
				}

				return ""
			}
		}
	}
</script>
