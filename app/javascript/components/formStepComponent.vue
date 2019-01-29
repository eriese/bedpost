<template>
	<div v-show="index == $parent.curIndex">
		<slot></slot>
	</div>
</template>

<script>


	export default {
		name: "form_step",
		data: function() {
			return {
				index: 0
			}
		},
		computed: {
			fields: function() {
				return this.$children.filter((c) => c.$options.name == "field_errors")
			}
		},
		methods: {
			checkReady: function() {
				for (var i = 0; i < this.fields.length; i++) {
					if (!this.fields[i].isValid()) {
						this.fields[i].setFocus();
						return false;
					}
				}

				return true;
			}
		}
	}
</script>
