<template>
	<div>
		<div class="clear-fix" v-for="(comp, index) in list" :key="comp._id" ref="list_item">
			<button v-if="list.length > 1" type="button" @click="removeFromList(index)">-</button>
			<button v-if="index > 0" type="button" @click="moveSpaces(index,-1)">^</button>
			<button v-if="index < list.length - 1" type="button" @click="moveSpaces(index,1)">V</button>
			<component :is="componentType" :base-name="`${baseName}[${index}]`" v-model="list[index]" :watch-key="index"></component>
		</div>
		<button type="button" @click="addToList">Add Another</button>
	</div>
</template>

<script>
	import {TweenLite} from "gsap/TweenMax";
	export default {
		name: "dynamic_field_list",
		props: ["componentType", "list", "baseName", "dummyKey"],
		computed: {
			dummy: function() {
				return gon[this.dummyKey || "dummy"]
			},
			idKey: function() {
				return this.dummy.hasOwnProperty("id") ? "id" : "_id"
			}
		},
		methods: {
			addToList() {
				let newObj = Object.assign({}, this.dummy);
				newObj[this.idKey] = Date.now();
				this.list.push(newObj);
			},
			removeFromList(index) {
				TweenLite.to(this.$refs.list_item[index], 0.3, {opacity: 0, onComplete: () => {
					this.list.splice(index, 1);
				}})

			},
			moveSpaces(index, numSpaces) {
				Array.move(this.list, index, index + numSpaces);
			}
		}
	}
</script>
