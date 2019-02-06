<template>
	<div class="stepper" >
		<div :class="stepClass">
			<div class="step-inner" ref="inner" role="form" aria-labeledby="stepper-aria-label">
				<slot :step-ready="setStepReady" :num-steps="numSteps"></slot>
			</div>
			<div class="step-nav">
				<ul class="prog-buttons clear-fix" :aria-label="$root.t('helpers.form_stepper.button_container')">
					<li class="next" v-if="curIndex < numSteps - 1">
						<button class="not-button" @click="next" type="button" :disabled="curStepPending" :title="$root.t('next')">
							<svg viewBox="0 0 100 100" focusable="false"><path d="M 10,50 L 60,100 L 70,90 L 30,50  L 70,10 L 60,0 Z" class="arrow" transform="translate(100, 100) rotate(180) "></path></svg>
						</button>
					</li>
					<li class="next" v-if="curIndex == numSteps - 1">
						<slot name="last-button"><button class="not-button last" type="button"@click="next">{{lastButton || "Send"}}</button></slot>
					</li>
					<li class="prev">
						<button class="not-button" @click="back" type="button" :style="curIndex == 0 ? {visibility: 'hidden'} : {}" :title="$root.t('previous')">
							<svg viewBox="0 0 100 100" focusable="false"><path d="M 10,50 L 60,100 L 70,90 L 30,50  L 70,10 L 60,0 Z" class="arrow"></path></svg>
						</button>
					</li>
				</ul>

				<div class="prog-dots" role="progressBar" aria-valuemin="1" :aria-valuemax="numSteps" :aria-valuenow="curIndex + 1" tabindex="0">
					<div v-for="i in numSteps" class="prog-dot" :class="{current: i - 1 == curIndex}"></div>
				</div>
			</div>
		</div>
		<slot name="additional" :cur-opts="curOpts" :cur-field="curField"></slot>
	</div>
</template>

<script>
import Flickity from 'flickity';
export default {
	name: "form_stepper",
	data: function () {
		return {
			curIndex: 0,
			internalInd: 0,
			indexes: [],
			numSteps: 0,
			flik: null,
			readies: [],
			curStepPending: true,
			curOpts: {},
			curField: {},
			flickityOptions: {
				initialIndex: 0,
				prevNextButtons: false,
				pageDots: false,
				wrapAround: false,
				freeScroll: false,
				cellSelector: ".form-step",
				draggable: false
			}
		}
	},
	props: {
		uniform: {
			type: Boolean,
			default: true
		},
		stepClass: String,
		lastButton: String
	},
	watch: {
		$children: function(newVal, oldVal) {
			this.processChildren(newVal, oldVal)
		},
		curIndex: function(newInd, oldInd) {
			this.processIndex(newInd, oldInd)
		}
	},
	methods: {
		getCurStep: function() {
			return this.$children[this.internalInd];
		},
		processIndex: function(newInd, oldInd) {
			this.internalInd = this.indexes[newInd];
			let curStep = this.getCurStep();
			this.curOpts = curStep.opts;
			this.curField = curStep.fields[0].field;
			this.setStepReady();
		},
		next: function() {
			if (!this.getCurStep().checkReady()) {
				return
			}

			if (this.curIndex < this.numSteps - 1) {
				this.flik.next();
			}
		},
		back: function() {
			if (this.curIndex > 0) {
				this.flik.previous()
			}
		},
		findNext: function() {
			let nextInd = this.readies.indexOf(false, this.curIndex);
			if (nextInd == -1 && this.curIndex > 0) {
				nextInd = this.readies.indexOf(false)
			}

			if(nextInd > -1) {
				this.flik.selectCell(nextInd)
			}
		},
		setIndex: function(newIndex) {
			this.curIndex = newIndex;
		},
		setStepReady: function(isReady) {
			if (typeof isReady != "boolean") {
				isReady = this.getCurStep().checkReady();
			}
			this.readies[this.curIndex] = isReady;
			this.curStepPending = !isReady;

			this.flik.options.draggable = isReady;
			this.flik.updateDraggable();
		},
		allReady: function() {
			return this.readies.indexOf(false) == -1;
		},
		processChildren: function(newChildren, oldChildren) {
			let newSteps = []
			let newReadies = [];
			let newIndexes = [];
			for (let i = 0; i < newChildren.length; i++) {
				let child = newChildren[i];
				if (child.$options.name == "form_step") {
					let oldIndex = child.index;
					child.index = newSteps.length;
					newSteps.push(child);
					newIndexes.push(i);

					newReadies.push(oldIndex == child.index ? this.readies[oldIndex] : false)
				}
			}

			this.readies = newReadies;
			this.numSteps = newSteps.length;
			this.indexes = newIndexes;

			this.processIndex(this.curIndex);
			this.setStepReady();
		}
	},
	mounted: function() {
		this.flickityOptions.on = {change: this.setIndex}
		this.flik = new Flickity(this.$refs.inner, this.flickityOptions)

		this.processChildren(this.$children, []);
	}
}
</script>
