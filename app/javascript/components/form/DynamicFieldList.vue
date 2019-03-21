<template>
	<div>
		<div class="clear-fix dynamic-field step" v-for="(comp, index) in list" :key="comp._id" ref="list_item" @focusin="setFocus(index)" @click="setFocus(index, true)">
			<div class="dynamic-field-buttons" @focusin.stop>
				<arrow-button class="not-button" v-if="list.length > 1" @click.stop="removeFromList(index)" direction="x" t-key="remove"></arrow-button>
				<arrow-button class="not-button" v-if="index > 0" v-bind="{direction: 'up', tKey: 'move_up'}" @click.stop="moveSpaces(index,-1)"></arrow-button>
				<arrow-button class="not-button" v-if="index < list.length - 1" v-bind="{direction: 'down', tKey: 'move_down'}" @click.stop="moveSpaces(index,1)">V</arrow-button>
			</div>
			<component ref="list_component" :is="componentType" :base-name="`${baseName}[${index}]`" v-model="list[index]" :watch-key="index"></component>
		</div>
		<button type="button" @click="addToList">Add Another</button>
	</div>
</template>

<script>
	import {TweenLite} from "gsap/TweenMax";
	export default {
		name: "dynamic_field_list",
		data: function() {
			return {
				focusIndex: 100
			}
		},
		props: ["componentType", "list", "baseName", "dummyKey", "tabbable"],
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
				this.$nextTick(() => {
					this.setFocus(this.list.length - 1, true)
				})
			},
			removeFromList(index) {
				TweenLite.to(this.$refs.list_item[index], 0.3, {opacity: 0, onComplete: () => {
					this.list.splice(index, 1);
					TweenLite.set(this.$refs.list_item, {opacity: 1});
				}})

			},
			moveSpaces(index, numSpaces) {
				let newInd = index + numSpaces;
				if (index == this.focusIndex) {
					this.focusIndex = newInd;
				} else if (numSpaces < 0 && newInd <= this.focusIndex && index >= this.focusIndex) {
					this.focusIndex += 1;
				} else if (numSpaces > 0 && newInd >= this.focusIndex && index <= this.focusIndex) {
					this.focusIndex -= 1;
				}
				Array.move(this.list, index, index + numSpaces);
			},
			blurChild(index) {
				setTimeout((vm) => {
					if (vm.focusIndex != index) {
						vm.$refs.list_component[index].blur();
					}
				}, 50, this);
			},
			focusChild(index) {
				if (this.focusIndex != index) {
					this.focusIndex = index;
					this.$refs.list_component[index].focus()
				}
			},
			setFocus(index, focusFirst) {
				if (index == this.focusIndex) {return;}
				this.focusIndex = index
				for (let i = 0; i < this.$refs.list_component.length; i++) {
					let comp = this.$refs.list_component[i]
					if (comp.watchKey == this.focusIndex) {
						comp[focusFirst ? 'focusFirst' : 'focus']();
					} else {
						comp.blur();
					}
				}
			}
		},
		mounted: function() {
			this.setFocus(0);
		}
	}
</script>
