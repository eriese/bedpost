<template>
	<div @mouseover="onHover(true)" @mouseleave="onHover(false)" role="presentation">
		<slot v-bind="slotScope"></slot>
		<div v-html="errorHTML"></div>
		<slot name="additional"></slot>
	</div>
</template>

<script>
import inputSlot from '@mixins/inputSlot';
import {lazyChild, lazyParent} from '@mixins/lazyCoupled';
import validatedField from '@mixins/validatedField';
/**
 * A component that wraps a form control and uses its validations to display error messages. Works best with parent [VuelidateFormComponent]{@link module:components/form/VuelidateFormComponent}
 *
 * @module
 * @vue-data {boolean} focused=false is the component's form control focused?
 * @vue-data {boolean} hovered=false is the component's form control being hovered over?
 * @vue-data {HTMLElement} input=null the element of the slotted form control
 * @vue-prop {string} modelName the name of the model this form is for
 * @vue-computed {string} field the name of the field this form input is for
 * @vue-prop {boolean} validate does this field have validations to run?
 * @vue-computed {boolean} validity whether this field is currently valid. This doesn't take dirty state or anything besides pure validity into account
 * @vue-computed {string} errorMsg the error message to display. chooses the first validation error and displays it
 * @mixes inputSlot
 * @emits module:components/form/FieldErrorsComponent~input-blur with new validity value whenever validity changes
 * @listens input.onfocus
 * @listens input.onblur
 */
export default {
	name: 'field_errors',
	mixins: [inputSlot, lazyChild, lazyParent, validatedField],
	data: function() {
		return {
			focused: false,
			hovered: false,
			input: null,
		};
	},
	props: {
		isDate: Boolean,
		modelName: String,
	},
	computed: {
		field() {
			let expression = this.$vnode.data.model.expression.split('.');
			return expression[expression.length - 1];
		},
		slotScope() {
			return {
				...this.inputSlotScope,
				onBlur: this.onBlur,
				onFocus: this.onFocus,
				ariaRequired: this.$v && this.$v.blank !== undefined,
				ariaInvalid: this.$v && this.$v.$invalid && (this.$v.$dirty || this.$v.submitted === false),
				focused: this.focused || this.hovered,
				focusedOnly: this.focused,
			};
		},

	},
	watch: {
		/**
		 * Watch the validity value
		 *
		 * @param  {boolean} newVal the new validity value
		 * @emits module:components/form/FieldErrorsComponent~input-blur
		 */
		validity: function (newVal) {
			this.$emit('input-blur', this, newVal);
		}
	},
	methods: {
		/**
		 * @summary Callback for {@link event:input.onblur}
		 * @description sets the focused value and runs validation
		 */
		onBlur() {
			this.focused = false;
			this.$emit('child-blur');
			if(this.$v) {
				this.$v.$touch();
			}
		},
		/**
		 * @summary Callback for {@link event:input.onfocus}
		 * @description sets the focused value
		 */
		onFocus() {
			this.focused = true;
			this.$emit('child-focus');
		},
		/**
		 * Focus the input element
		 */
		setFocus() {
			this.input.focus();
		},
		/**
		 * Callback for mousein and mouseout events
		 *
		 * @param  {boolean} isHovered is the mouse in?
		 */
		onHover(isHovered) {
			this.hovered = isHovered;
		},
		onChildMounted() {
			if (!this.input) {
				this.input = this.$el.querySelector('input, select');
			}
		}
	},
	mounted() {
		// get the input
		this.input = this.$el.querySelector('input, select');
		// if this is a date, convert the value to a date object
		if (this.isDate) {
			if (!this.model) {
				this.model = new Date();
			}
			else {
				let offset = new Date().getTimezoneOffset() * 60 * 1000;
				let timestamp = Date.parse(this.model);
				this.model = new Date(timestamp + offset);
			}
		}

		// if there's an input, we're not waiting on a lazy-loaded child
		if (this.input) {
			this.$parent.$emit('lazy-child-present');
		}
	},
};

/**
 * An event to update the parent component on the validity of the field
 *
 * @event module:components/form/FieldErrorsComponent~input-blur
 * @property {VueComponent} component the component emitting the event
 * @property {boolean} valid the new validity value of the emitting component's input field
 */
</script>
