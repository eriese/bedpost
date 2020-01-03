<template>
	<div class="input--has-close-button">
		<input type="file" v-bind="boundAttrs" v-on="cListeners" ref="input">
		<div class="input--has-close-button__button-container">
			<arrow-button shape="x" class="cta--is-inverted input--has-close-button__close-button cta--is-arrow--is-small" v-show="boundAttrs.disabled" @click="clearFiles"></arrow-button>
		</div>
	</div>
</template>

<script>
import customInput from '@mixins/customInput';

/**
 * A component to add more intuitive functionality to a file input. Provides a transparent wrapper around the file input
 *
 * @module
 * @mixes customInput
 * @vue-computed boundAttrs						inherited attributes to bind to the input
 */
export default {
	name: 'file-input',
	mixins: [customInput],
	inheritAttrs: false,
	model: {
		prop: 'files'
	},
	computed: {
		boundAttrs() {
			let attrs = {...this.$attrs};
			delete attrs.value;
			attrs.disabled = this.$refs.input && this.$refs.input.files.length > 0;
			return attrs;
		}
	},
	methods: {
		clearFiles() {
			// change to text input so we can clear the value
			this.$refs.input.type = 'text';
			this.$refs.input.value = '';
			// change back to file
			this.$refs.input.type = 'file';
			// emit an input event
			this.cListeners[this.inputEvent]();
		}
	}
};
</script>
