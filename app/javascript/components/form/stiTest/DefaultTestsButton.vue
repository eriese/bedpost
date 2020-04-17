<template>
	<button type="button" class="cta cta--is-compact" :title="title" @click="populateDefaults">{{ text }}</button>
</template>

<script>
export default {
	name: 'default-test-button',
	props: ['category', 'value'],
	data() {
		return {
			diagnoses: gon.diagnoses,
		};
	},
	computed: {
		text() {
			return this.$_t(this.category, {scope: 'sti_tests.default_tests'});
		},
		title() {
			return this.$_t('sti_tests.new.default_tests_title', {category: this.text});
		}
	},
	methods: {
		populateDefaults() {
			const that = this;
			let id = Date.now();
			let emptyVals = that.value.filter((v) => v.tested_for_id === null);
			that.diagnoses.forEach((d) => {
				if (d.category.indexOf(that.category) < 0) { return; }

				const preExisting = that.value.find((v) => v.tested_for_id == d._id && v._destroy !== true);
				if (preExisting !== undefined) { return; }

				if (emptyVals.length) {
					emptyVals.pop().tested_for_id = d._id;
				} else {
					that.$emit('populate', {tested_for_id: d._id, _id: id++});
				}
			});
		}
	}
};
</script>
