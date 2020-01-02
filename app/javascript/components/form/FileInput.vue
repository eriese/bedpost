<template>
	<div class="input--has-close-button">
		<input :type="type" v-bind="boundAttrs" v-on="fileInputListeners" ref="input">
		<div class="input--has-close-button__button-container">
			<arrow-button shape="x" class="cta--is-inverted input--has-close-button__close-button cta--is-arrow--is-small" v-show="boundAttrs.disabled" @click="clearFiles"></arrow-button>
		</div>
	</div>
</template>

<script>
import customInput from '@mixins/customInput';
export default {
	name: 'file-input',
	mixins: [customInput],
	inheritAttrs: false,
	model: {
		event: 'change',
		prop: 'files'
	},
	data() {
		return {
			files: [],
			type: 'file'
		};
	},
	computed: {
		fileInputListeners() {
			let listeners = {...this.cListeners};
			let vm = this;
			listeners[this.inputEvent] = function(e) {
				vm.files = e.target.files;
				vm.$emit('input', vm.files);
			};

			return listeners;
		},
		boundAttrs() {
			let attrs = {...this.$attrs};
			delete attrs.value;
			attrs.disabled = this.files.length > 0;
			return attrs;
		}
	},
	methods: {
		clearFiles() {
			this.type = 'text';
			this.$refs.input.value = '';
			this.files = [];
			this.$nextTick(() => {
				this.type = 'file';
			});
		}
	}
};
</script>
