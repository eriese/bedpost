<template>
	<div>
		<div v-for="(comp, index) in list" :key="comp[idKey]" ref="list_item">
			<div v-if="showDeleted || !comp._destroy" class="dynamic-field step" @focusin="setFocus(index)" @click="setFocus(index, true)" :class="{deleted: comp._destroy}">
				<div class="dynamic-field-buttons clear-fix" @focusin.stop>
					<arrow-button class="not-button" v-if="index > firstIndex" v-bind="{direction: 'up', tKey: 'move_up', shape: 'arrow'}" @click.stop="moveSpaces(index,-1)"></arrow-button>
					<arrow-button class="not-button" v-if="index < lastIndex" v-bind="{direction: 'down', tKey: 'move_down', shape: 'arrow'}" @click.stop="moveSpaces(index,1)"></arrow-button>
					<arrow-button class="not-button" shape="x" v-if="optional || numSubmitting > 1" @click.stop="removeFromList(index)" t-key="remove"></arrow-button>
				</div>
				<component ref="list_component" :is="componentType" :base-name="`${baseName}[${index}]`" v-model="list[index]" :watch-key="index" :tracked="trackInList" class="clear" @track="track"></component>
			</div>
			<deleted-child v-else :base-name="`${baseName}[${index}]`" :item="list[index]" :id-key="idKey"></deleted-child>
		</div>
		<button type="button" @click="addToList">Add Another</button>
	</div>
</template>

<script>
	import {TweenLite} from "gsap/TweenMax";
	import deletedChild from '@components/functional/DeletedChild.vue';

	export default {
		name: "dynamic_field_list",
		components: {
			'deleted-child': deletedChild
		},
		data: function() {
			return {
				focusIndex: 100,
				// an object for tracking list properties, to be defined by the list items
				trackInList: {},
				numSubmitting: 0,
				toDelete: []
			}
		},
		props: ["componentType", "list", "baseName", "dummyKey", "showDeleted", "optional"],
		computed: {
			dummy: function() {
				return gon[this.dummyKey || "dummy"]
			},
			idKey: function() {
				return this.dummy.hasOwnProperty("id") ? "id" : "_id"
			},
			lastIndex: function() {
				return this.list.findLastIndex((d) => !d._destroy);
			},
			firstIndex: function() {
				return this.list.findIndex((d) => !d._destroy);
			}
		},
		methods: {
			addToList() {
				let newObj = Object.assign({}, this.dummy, {newRecord: true, position: this.numSubmitting});
				newObj[this.idKey] = Date.now();
				this.list.push(newObj);
				this.numSubmitting += 1;
				this.$nextTick(() => {
					this.setFocus(this.list.length - 1, true)
				})
			},
			removeFromList(index) {
				TweenLite.to(this.$refs.list_item[index], 0.3, {opacity: 0, onComplete: () => {
					let deleted = this.list.splice(index, 1)[0];
					deleted._destroy = true;
					let oldPos = deleted.position;
					this.list.splice(index,0,deleted);
					if (oldPos < this.numSubmitting) {
						this.updateIndices(index, oldPos);
					}
					this.numSubmitting -= 1;

					this.$nextTick(() => {
						TweenLite.set(this.$refs.list_item, {opacity: 1});
						if (index == this.focusIndex) {
							this.focusIndex = this.list.length;
						} else if (index < this.focusIndex) {
							this.focusIndex -= 1;
						}
					})
				}})

			},
			moveSpaces(index, numSpaces) {
				let newInd = index + numSpaces;
				while (this.list[newInd]._destroy) {
					newInd += numSpaces;
				}

				if (index == this.focusIndex) {
					this.focusIndex = newInd;
				} else if (numSpaces < 0 && newInd <= this.focusIndex && index >= this.focusIndex) {
					this.focusIndex += 1;
				} else if (numSpaces > 0 && newInd >= this.focusIndex && index <= this.focusIndex) {
					this.focusIndex -= 1;
				}

				let oldStart = Math.min(index, newInd);
				let oldPos = this.list[oldStart].position

				Array.move(this.list, index, newInd);
				this.updateIndices(oldStart, oldPos);
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
			},
			track(key, val) {
				if (key instanceof Array) {
					for (var i = 0; i < key.length; i++) {
						this.$set(this.trackInList, key[i], this.trackInList[key[i]]);
					}
				}
				this.$set(this.trackInList, key, val);
			},
			updateIndices(startVal, startInd) {
				for (var i = startVal; i < this.list.length; i++) {
					if (!this.list[i]._destroy) {
						this.$set(this.list[i], 'position', startInd++)
					}
				}
			}
		},
		mounted: function() {
			this.numSubmitting = this.list.length;
			this.updateIndices(0,0);
			this.setFocus(this.lastIndex);
		}
	}
</script>
