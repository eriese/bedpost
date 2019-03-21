<template>
	<div>
		<div class="clear-fix dynamic-field step" v-for="(comp, index) in list" :key="comp._id" ref="list_item">
			<div class="dynamic-field-buttons">
				<arrow-button class="not-button" v-if="list.length > 1" @click="removeFromList(index)" direction="x" t-key="remove"></arrow-button>
				<arrow-button class="not-button" v-if="index > 0" v-bind="{direction: 'up', tKey: 'move_up'}" @click="moveSpaces(index,-1)"></arrow-button>
				<arrow-button class="not-button" v-if="index < list.length - 1" v-bind="{direction: 'down', tKey: 'move_down'}" @click="moveSpaces(index,1)">V</arrow-button>
			</div>
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
					TweenLite.set(this.$refs.list_item, {opacity: 1});
				}})

			},
			moveSpaces(index, numSpaces) {
				Array.move(this.list, index, index + numSpaces);
			}
		}
	}
</script>
