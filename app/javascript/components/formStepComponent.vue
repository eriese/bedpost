<template>
	<div class="form-step">
		<div id="stepper-aria-label" class="aria-only" aria-live="polite">{{`step ${index + 1} of ${numSteps}`}}</div>
		<slot :field-blur="fieldBlur"></slot>
	</div>
</template>

<script>
	export default {
		name: "form_step",
		data: function() {
			return {
				index: 0,
				readies: []
			}
		},
		props: {
			optional: {
				type: Boolean,
				default: false,
			},
			numSteps: Number,
			opts: {
				type: Object,
				default: () => {return {}}
			}
		},
		computed: {
			fields: function() {
				return this.$children.filter((c) => c.$options.name == "field_errors")
			}
		},
		methods: {
			checkReady: function(focusSomething) {
				let falseInd = this.readies.indexOf(false)
				if (falseInd > -1) {
					this.fields[falseInd].setFocus();
					return false;
				}

				if (focusSomething) {
					this.fields[0] && this.fields[0].setFocus();
				}

				return true;
			},
			fieldBlur(field, valid) {
				let ind = this.fields.indexOf(field);
				let old = this.readies[ind]

				if (old == valid) {
					return;
				}

				this.readies[ind] = valid;

				let sendValid = valid;
				if (valid) {
					sendValid = this.readies.indexOf(false) == -1;
				}

				this.$emit("step-ready", sendValid);
			}
		},
		mounted: function() {
			this.readies = this.fields.map((f) => f.isValid())
		}
	}
</script>
