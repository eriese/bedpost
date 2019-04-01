<template>
	<div v-if="!item.newRecord">
		<input type="hidden" :name="`${baseName}[${idKey}]`" :value="item[idKey]">
		<input type="hidden" :name="`${baseName}[_destroy]`" value="true">
	</div>
</template>

<script>
	export default {
		name: "deleted-child",
		props: ['baseName', 'idKey', 'item']
	}
</script>
