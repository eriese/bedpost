<template>
	<div class="stepper" >
		<div :class="stepClass">
			<div class="step-inner" ref="inner" role="form" aria-labeledby="stepper-aria-label">
				<slot :step-ready="setStepComplete" :num-steps="numSteps"></slot>
			</div>
			<div class="step-nav">
				<ul class="prog-buttons clear-fix" :aria-label="$root.t('helpers.form_stepper.button_container')">
					<li class="next" v-if="curIndex == numSteps - 1">
						<slot name="last-button"><button class="not-button last" type="button"@click="next">{{lastButton || "Send"}}</button></slot>
					</li>
					<li v-for="btn in buttons" v-if="btn.if" :class="btn.clazz">
						<button v-bind="btn.bind || {}" @click="btn.click" :title="$root.t(btn.key)" class="not-button" type="button">
							<svg viewBox="0 0 100 100" focusable="false"><path d="M 10,50 L 60,100 L 70,90 L 30,50  L 70,10 L 60,0 Z" class="arrow" :transform="btn.transform"></path></svg>
						</button>
					</li>
				</ul>

				<div class="prog-dots" role="progressBar" aria-valuemin="1" :aria-valuemax="numSteps" :aria-valuenow="curIndex + 1" tabindex="0">
					<div v-for="i in numSteps" class="prog-dot" :class="{current: i - 1 == curIndex}"></div>
				</div>
			</div>
		</div>
	</div>
</template>

<script>
import Flickity from 'flickity';

/**
 * A component to make multi-step forms. Uses [Flickity]{@link https://github.com/metafizzy/flickity} to handle form step navigations
 * @module
 * @vue-data {Number} curIndex=0 the current step index
 * @vue-data {Number} internalInd=0 the index of the current step in the $children array
 * @vue-data {Number[]} [indexes=[]] an array mapping the step indexes to their internal indexes
 * @vue-data {Number} numSteps=0 the number of steps in the stepper
 * @vue-data {Boolean[]} completes an array to keep track of which steps have been visited and completed
 * @vue-data {Boolean} curStepPending is the current step not yet ready?
 * @vue-data {Object} FlickityOptions the options for the flickity instance
 * @listens module:components/stepper/FormStepComponent~step-ready
 */
export default {
	name: "form_stepper",
	data: function () {
		return {
			curIndex: 0, // the current step index
			internalInd: 0, // the index of the current step in the $children array
			indexes: [], // an array mapping the step indexes to their internal indexes
			numSteps: 0, // the number of steps in the stepper
			flik: null, // the Flickity instance
			completes: [], // an array to keep track of which steps have been visited and completed
			curStepPending: true, // is the current step not yet ready?
			flickityOptions: { // the options for the flickity instance
				initialIndex: 0,
				prevNextButtons: false, // we're going to do our own buttons
				pageDots: false, // we're going to do our own page dots
				wrapAround: false, // don't wrap around
				freeScroll: false, // lock on steps
				cellSelector: ".form-step",
				draggable: false // we're going to manipulate draggable in the code
			}
		}
	},
	props: {
		uniform: { // should the heights of all the steps be uniform
			type: Boolean,
			default: true
		},
		stepClass: String, // a class to add to steps
		lastButton: String // text of the last button if nothing is provided for the slot
	},
	watch: {
		$children: function(newVal, oldVal) {
			this.processChildren(newVal, oldVal)
		},
		curIndex: function(newInd, oldInd) {
			this.processIndex(newInd, oldInd)
		}
	},
	computed: {
		buttons: function() {
			return [{
				key: "next",
				clazz: "next",
				if: this.curIndex < this.numSteps - 1,
				bind: {
					disabled: this.curStepPending
				},
				click: this.next,
				transform: "translate(100, 100) rotate(180)"
			}, {
				key: "previous",
				clazz: "prev",
				if: this.numSteps > 1 && this.curIndex > 0,
				click: this.back
			}]
		}
	},
	methods: {
		/** get the current step component */
		getCurStep: function() {
			// get the child at the internal index
			return this.$children[this.internalInd];
		},
		/** process a change to the index */
		processIndex: function(newInd, oldInd) {
			// set the internal index
			this.internalInd = this.indexes[newInd];
			// get the completeness of the new step
			this.setStepComplete();
		},
		/** move to the next step */
		next: function() {
			// don't move forward if the step is not ready
			if (!this.getCurStep().checkComplete()) {
				return
			}

			// move forward using the flikity instance
			if (this.curIndex < this.numSteps - 1) {
				this.flik.next();
			}
		},
		/** move to the previous step */
		back: function() {
			// only if we're not already on the first one
			if (this.curIndex > 0) {
				this.flik.previous()
			}
		},
		/** find the next step that isn't ready */
		findNext: function() {
			// start looking from the current index
			let nextInd = this.completes.indexOf(false, this.curIndex);
			// otherwise look in the whole array
			if (nextInd == -1 && this.curIndex > 0) {
				nextInd = this.completes.indexOf(false)
			}

			// select that cell
			if(nextInd > -1) {
				this.flik.selectCell(nextInd)
			}
		},
		/** set the index (called from FLickity onChange) */
		setIndex: function(newIndex) {
			this.curIndex = newIndex;
		},
		/** set the readiness of the current step
		* (called from a lot of places including the blur event on the step's inputs) */
		setStepComplete: function(isComplete) {
			// if an isComplete isn't provided, get one from the current step
			if (typeof isComplete != "boolean") {
				isComplete = this.getCurStep().checkComplete();
			}

			// set readiness in the completes array and update whether this step is pending
			this.completes[this.curIndex] = isComplete;
			this.curStepPending = !isComplete;

			// allow dragging on the flickity instance if the step is ready
			this.flik.options.draggable = isComplete;
			this.flik.updateDraggable();
		},
		/** are all steps ready */
		allReady: function() {
			return this.completes.indexOf(false) == -1;
		},
		/** process the children to get information about the steps */
		processChildren: function(newChildren, oldChildren) {
			// make new arrays for the data
			let newCompletes = [];
			let newIndexes = [];

			// go through all the children
			for (let i = 0; i < newChildren.length; i++) {
				let child = newChildren[i];
				// if it's a form step
				if (child.$options.name == "form_step") {
					// get the child's previous index if it had one
					let oldIndex = child.index;
					// set its new index
					child.index = newIndexes.length;

					//add the index in the full $children array to the indexes array at the child's new index
					newIndexes.push(i);

					// if the child hasn't changed indexes, keep its old isComplete value, otherwise set it to false
					// all steps default to not ready because the user must at least visit them for them to be considered complete
					newCompletes.push(oldIndex == child.index ? this.completes[oldIndex] : false)
				}
			}

			// set the data
			this.completes = newCompletes;
			this.numSteps = newIndexes.length;
			this.indexes = newIndexes;

			// re-process the current index
			this.processIndex(this.curIndex);
			// get whether the current step is complete
			this.setStepComplete();
		}
	},
	mounted: function() {
		// make a flikity instance
		this.flickityOptions.on = {change: this.setIndex}
		this.flik = new Flickity(this.$refs.inner, this.flickityOptions)

		// process the children
		this.processChildren(this.$children);
		this.$emit("stepper-mounted", this);
	},
	beforeDestroy: function() {
		this.flik.destroy();
	}
}
</script>