<template>
	<div class="dynamic-field-list">
		<slot></slot>
		<div v-for="(comp, index) in list" :key="comp[idKey]" ref="list_item" class="dynamic-field-list__item">
			<div v-if="showDeleted || !comp._destroy" @focusin="setFocus(index)" @click="setFocus(index, true)" class="dynamic-field step" :class="{incomplete: $vEach[index] && $vEach[index].$anyDirty && $vEach[index].$invalid, deleted: comp._destroy}">
				<div class="dynamic-field-buttons clear-fix" @focusin.stop>
					<arrow-button class="link cta--is-arrow--is-small" v-if="index > firstIndex" v-bind="{direction: 'up', tKey: 'move_up', shape: 'arrow'}" @click.stop="moveSpaces(index,-1)"></arrow-button>
					<arrow-button class="link cta--is-arrow--is-small" v-if="index < lastIndex" v-bind="{direction: 'down', tKey: 'move_down', shape: 'arrow'}" @click.stop="moveSpaces(index,1)"></arrow-button>
					<arrow-button class="link cta--is-arrow--is-small" shape="x" v-if="optional || numSubmitting > 1" @click.stop="removeFromList(index)" t-key="remove"></arrow-button>
				</div>
				<component ref="list_component" :is="componentType" :base-name="`${baseName}[${index}]`" v-model="list[index]" :watch-key="index" :tracked="tracker" class="clear" @track="track" @start-tracking="startTracking" :$v="$vEach[index]"></component>
			</div>
			<deleted-child v-else :base-name="`${baseName}[${index}]`" :item="list[index]" :id-key="idKey"></deleted-child>
		</div>
		<button type="button" class="cta cta--is-form-submit cta--is-add-btn cta--is-add-btn--is-small" @click="addToList" title="Add Another"></button>
	</div>
</template>

<script>
import {gsap} from 'gsap';
import deletedChild from '@components/functional/DeletedChild.vue';
import {lazyParent} from '@mixins/lazyCoupled';

export default {
	name: 'dynamic_field_list',
	mixins: [lazyParent],
	components: {
		'deleted-child': deletedChild
	},
	data: function() {
		return {
			focusIndex: 100,
			tracker: null,
			numSubmitting: 0,
			toDelete: [],
		};
	},
	props: ['componentType', 'value', 'baseName', 'dummyKey', 'showDeleted', 'optional', '$v'],
	computed: {
		dummy: function() {
			return gon[this.dummyKey || 'dummy'];
		},
		idKey: function() {
			return Object.hasOwnProperty(this.dummy, 'id') ? 'id' : '_id';
		},
		lastIndex: function() {
			return this.list.findLastIndex((d) => !d._destroy);
		},
		firstIndex: function() {
			return this.list.findIndex((d) => !d._destroy);
		},
		$vEach: function() {
			return this.$v && this.$v.$each && this.$v.$each.$iter || [];
		},
		list: function() {
			return this.value.slice();
		}
	},
	methods: {
		addToList() {
			let newObj = Object.assign({}, this.dummy, {newRecord: true, position: this.numSubmitting});
			newObj[this.idKey] = Date.now();
			this.list.push(newObj);
			this.numSubmitting += 1;
			this.onInput();
			this.$nextTick(() => {
				this.setFocus(this.list.length - 1, true);
			});
		},
		removeFromList(index) {
			gsap.to(this.$refs.list_item[index], 0.3, {opacity: 0, onComplete: () => {
				let deleted = this.list[index];
				deleted._destroy = true;
				let oldPos = deleted.position;
				if (oldPos < this.numSubmitting) {
					this.updateIndices(index, oldPos);
				}
				this.numSubmitting -= 1;

				this.$nextTick(() => {
					gsap.set(this.$refs.list_item, {opacity: 1});
				});
			}});
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
			let oldPos = this.list[oldStart].position;

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
				this.$refs.list_component[index].focus();
			}
		},
		setFocus(index, focusFirst) {
			if (index == this.focusIndex || !this.$refs.list_component) {return;}
			this.focusIndex = index;
			for (let i = 0; i < this.$refs.list_component.length; i++) {
				let comp = this.$refs.list_component[i];
				if (comp.watchKey == this.focusIndex) {
					comp[focusFirst ? 'focusFirst' : 'focus']();
				} else {
					comp.blur();
				}
			}
		},
		track() {
			this.tracker && this.tracker.update(this.list);
		},
		updateIndices(startVal, startInd) {
			for (var i = startVal; i < this.list.length; i++) {
				if (!this.list[i]._destroy) {
					this.$set(this.list[i], 'position', startInd++);
				}
			}

			this.onInput();
		},
		onChildMounted() {
			this.setFocus(this.lastIndex);
		},
		startTracking(trackerFactory) {
			if (this.tracker === null) {
				this.tracker = trackerFactory(this.list);
			}
		},
		onInput() {
			this.$emit('input', this.list);
		},
	},
	created() {
		this.numSubmitting = this.list.length;
		if (this.numSubmitting == 0 && !this.optional) {
			this.addToList();
		} else {
			this.updateIndices(0,0);
		}
	}
};
</script>
