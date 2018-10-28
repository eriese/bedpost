<template>
	<div class="field-errors" v-if="errorMsg">
		{{errorMsg}}
	</div>
</template>

<script>
	function getDefaults (validator, field, modelName) {
		let defaults = [
			{scope: `activemodel.errors.messages.${validator}`},
			{scope: `errors.attributes.${validator}`},
			{scope: `errors.messages.${validator}`}
		];

		if (modelName) {
			defaults.unshift({scope: `activemodel.errors.models.${modelName}.${validator}`})
			defaults.unshift({scope: `activemodel.errors.models.${modelName}.attributes.${field}.${validator}`})
		}
		return defaults;
	}

	export default {
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
				return this.v.formData[this.modelName] ? this.v.formData[this.modelName][this.field] : this.v.formData[this.field]
			},
			errorMsg: function() {
				let msg = this.submissionError[this.modelName];
				msg = msg ? msg[this.field] : this.submissionError[this.field];
				if (msg) {
					return msg;
				}

				if (!this.vField.$dirty) {
					return "";
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
