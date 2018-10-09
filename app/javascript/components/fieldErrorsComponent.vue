<template>
	<div class="errors" v-if="v[field].$dirty && v[field].$anyError">
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
			field: String,
			modelName: String
		},
		computed: {
			errorMsg: function() {
				let field = this.field;
				let vParams = this.v[field].$params
				for (var validator in vParams) {
					if (!this.v[field][validator]) {
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
