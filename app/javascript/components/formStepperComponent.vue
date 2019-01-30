<template>
	<div class="stepper" :class="stepClass">
		<div class="step-inner" ref="inner">
			<slot></slot>
		</div>
		<div class="prog-dots">
			<div>
				<div v-for="i in numSteps" class="prog-dot" :class="{current: i - 1 == curIndex}"></div>
			</div>
			<div class="prog-buttons">
				<button class="not-button" @click="back" type="button" :disabled="curIndex == 0">&lt</button>
				<button class="not-button" @click="next" type="button" v-if="curIndex < numSteps - 1">&gt</button>
				<slot name="last-button" v-if="curIndex == numSteps - 1"><button class="not-button last" type="button"@click="next">{{lastButton}}</button></slot>
			</div>
		</div>
	</div>
</template>

<script>
export default {
	name: "form_stepper",
	data: function () {
		return {
			curIndex: 0,
			numSteps: 0
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
	computed: {
		steps: function() {
			return this.$children.filter((c) => c.$options.name == "form_step")
		},
		curStep: function() {
			return this.steps[this.curIndex]
		}
	},
	methods: {
		next: function() {
			if (!this.curStep.checkReady()) {
				return
			}

			if (this.curIndex < this.numSteps - 1) {
				this.curIndex++;
			} else {
				this.$emit("finished")
			}
		},
		back: function() {
			if (this.curIndex > 0) {
				this.curIndex--;
			}
		}
	},
	mounted: function() {
		let maxHeight = 0;
		for (let i = 0; i < this.$children.length; i++) {
			let child = this.$children[i]
			if (child.$options.name == "form_step") {
				child.index = this.numSteps++;
				maxHeight = Math.max(maxHeight, child.$el.offsetHeight)
			}
		}
		if (this.uniform) {
			this.$refs.inner.style.height = maxHeight + "px"
		}
	}
}
</script>
