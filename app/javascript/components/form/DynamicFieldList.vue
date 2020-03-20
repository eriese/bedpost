<template>
	<fieldset :class="`dynamic-field-list dynamic-field-list--has-${componentType}s`" role="group" :aria-activedescendant="`dynamic-list-item-${focusIndex}`">
		<slot v-bind="{addToList}"></slot>
		<div v-for="comp in internalList" :key="comp.item[idKey]" ref="list_item" class="dynamic-field-list__item ">
			<div v-if="showDeleted || !comp.item._destroy" @focusin="setFocus(comp.index)" @click="setFocus(comp.index, true)" class="dynamic-field step" :class="[`dynamic-field--is-${componentType}`, {incomplete: $vEach[comp.index] && $vEach[comp.index].$error, blurred: comp.index != focusIndex, deleted: comp.item._destroy}]" role="group" :id="`dynamic-list-item-${comp.index}`">
				<div class="dynamic-field-buttons" @focusin.stop v-if="optional || numSubmitting > 1 || comp.index != firstIndex" role="toolbar">
					<arrow-button class="link cta--is-arrow--is-small" v-if="ordered && comp.index > firstIndex" v-bind="{direction: 'up', tKey: 'move_up', shape: 'arrow'}" @click.stop="moveSpaces(comp.index,-1)"></arrow-button>
					<arrow-button class="link cta--is-arrow--is-small" v-if="ordered && comp.index < lastIndex" v-bind="{direction: 'down', tKey: 'move_down', shape: 'arrow'}" @click.stop="moveSpaces(comp.index,1)"></arrow-button>
					<arrow-button class="link cta--is-arrow--is-small" shape="x" v-if="optional || numSubmitting > 1" @click.stop="removeFromList(comp.index)" t-key="remove"></arrow-button>
				</div>
				<component
					ref="list_component"
					v-model="comp.item"
					:class="{clear: ordered}"
					:is="componentType"
					:watch-key="comp.index"
					:tracker="tracker"
					:state="comp"
					:$v="$vEach[comp.index]"
					:base-name="`${baseName}[${comp.index}]`"
					@track="track"
					@start-tracking="startTracking"
					@input="onInput"></component>
			</div>
			<deleted-child v-else :base-name="`${baseName}[${comp.index}]`" :item="list[comp.index]" :id-key="idKey"></deleted-child>
		</div>
		<button type="button" class="cta cta--is-form-submit cta--is-add-btn cta--is-add-btn--is-small" @click="addToList" title="Add Another" aria-label="Add Another"></button>
	</fieldset>
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
			internalList: [],
			stateConstructor: null,
		};
	},
	props: ['componentType', 'value', 'baseName', 'dummyKey', 'showDeleted', 'optional', '$v', 'stateClass', 'formData', 'ordered'],
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
		list() {
			return this.internalList.map ((i) => i.item);
		}
	},
	methods: {
		addToList(objectProps) {
			let newObj = Object.assign({}, this.dummy, {newRecord: true, position: this.numSubmitting});
			newObj[this.idKey] = Date.now();
			if (objectProps && !(objectProps instanceof MouseEvent)) {
				Object.assign(newObj, objectProps)
			}

			let state = this.generateState(newObj);

			this.internalList.push(state);
			this.numSubmitting += 1;
			this.onInput();
			this.$nextTick(() => {
				this.setFocus(state.index, true);
			});
		},
		removeFromList(index) {
			gsap.to(this.$refs.list_item[index], 0.3, {opacity: 0, onComplete: () => {
				let deleted = this.list[index];
				this.$set(deleted, '_destroy', true);
				let oldPos = deleted.position;
				if (oldPos < this.numSubmitting) {
					this.updateIndices(index, oldPos);
				}
				this.numSubmitting -= 1;
				this.focusIndex -= 1;
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

			Array.move(this.internalList, index, newInd);
			this.updateIndices(oldStart, oldPos);
		},
		/**
		 * Focus the list item at the given index and blur all others
		 * @param {number} index      the index the item has in the list
		 * @param {boolean} focusFirst whether the item should set the focus on its first input
		 */
		setFocus(index, focusFirst) {
			// if there aren't items, do nothing
			if (!this.$refs.list_component) { return; }

			// if it's not a new index, just focus it
			if (index == this.focusIndex && this.$children[index].focus) {
				this.$children[index].focus();
				return;
			}

			// set the new index
			this.focusIndex = index;
			this.$refs.list_component.forEach((comp) => {
				// focus the selected item
				if (comp.watchKey == this.focusIndex) {
					comp[focusFirst ? 'focusFirst' : 'focus']();
				} else {
					// blur all others
					comp.blur();
				}
			})
		},
		track() {
			this.tracker && this.tracker.update(this.list);
		},
		updateIndices() {
			let startInd = 0;
			this.internalList.forEach((listItem, i) => {
				listItem.index = i;
				if (!listItem.item._destroy) {
					this.$set(listItem.item, 'position', startInd++);
				}
			})

			this.track();
			this.onInput();
		},
		onChildMounted() {
			this.setFocus(this.lastIndex);
		},
		startTracking(trackerFactory) {
			if (this.tracker === null) {
				this.tracker = trackerFactory(this.formData);
			}

			this.track();
		},
		onInput() {
			this.$emit('input', this.list);
		},
		generateState(listItem) {
			return new this.stateConstructor(listItem, this, this.baseName, this.internalList.length);
		},
		parseList() {
			this.internalList = this.value.map(this.generateState);
			this.updateIndices();
			this.setFocus(this.lastIndex);
		}
	},
	created: async function() {
		let mod;
		if (this.stateClass) {
			mod = await import( /* webpackChunkName: 'state' */ '@components/form/state/' + this.stateClass + '.js');
			this.stateConstructor = mod.default;
		} else {
			this.stateConstructor = (item) => {
				return {
					index: this.list.length,
					baseName: this.baseName,
					item
				}
			}
		}

		this.numSubmitting = this.value.length;
		if (this.numSubmitting == 0 && !this.optional) {
			this.addToList();
		} else {
			this.parseList();
		}
	}
};
</script>
