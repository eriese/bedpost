<template>
<fieldset class="contact-field-container" :class="{blurred: !focused, invalid: incomplete}" :aria-invalid="incomplete" :aria-labelledby="`as-sentence-${watchKey}`" :aria-describedby="`contact-error-${watchKey}`">
	<div v-if="incomplete && !focused" class="contact-error" aria-live="polite" :id="`contact-error-${watchKey}`">{{$_t('mongoid.errors.models.contact.incomplete')}} <div class="aria-only">{{$_t('mongoid.errors.models.contact.aria_incomplete', {index: watchKey + 1})}}</div></div>
	<legend class="aria-only" aria-live="polite" :id="`as-sentence-${watchKey}`">{{state.asSentence}}</legend>
	<input type="hidden" :value="value._id" :name="baseName + '[_id]'" v-if="!value.newRecord">
	<input type="hidden" :value="value.position" :name="baseName + '[position]'">
	<input type="hidden" :value="value.possible_contact_id" :name="baseName + '[possible_contact_id]'">
	<div class="contact-field" role="group">
		<contact-field-section
			class="narrow"
			v-model="state.contact.subject"
			field="subject"
			:state="state"
			@change="setContact('subject')"></contact-field-section>
		<contact-field-section
			class="narrow"
			v-model="state.contact_type"
			field="contact_type"
			:state="state"
			@change="setContact()"></contact-field-section>
		<contact-field-section
			class="narrow"
			v-model="state.contact.object"
			field="object"
			:state="state"
			@change="setContact('object')"></contact-field-section>
		<contact-field-section
			v-model="state.object_instrument_id"
			field="object_instrument_id"
			:state="state"
			@change="setContact()"></contact-field-section>
		<div class="field-section narrow">
			<p v-html="state.subjPossessive"></p>
		</div>
		<contact-field-section
			v-show="state.hasSubjectInstruments"
			v-model="state.subject_instrument_id"
			field="subject_instrument_id"
			:state="state"
			@change="setContact()"></contact-field-section>
	</div>
	<div class="contact-barriers clear-fix">
		<div>
			<barrier-input
				v-for="(bType, bKey) in barriers"
				ref="barriers"
				:key="state.baseName + bKey"
				:barrier="bType"
				:state="state"
				:base-name="state.baseName"
				:tracker="tracker"
				@change="updateBarriers"></barrier-input>
		</div>
	</div>
</fieldset>
</template>

<script>
import dynamicFieldListItem from '@mixins/dynamicFieldListItem';
import encounterContactFieldSection from '@components/form/encounter/EncounterContactFieldSection.vue';
import encounterContactBarrier from './EncounterContactBarrier.vue';
import { minLength, requiredUnless } from 'vuelidate/lib/validators';
import EncounterBarrierTracker from '@modules/encounterBarrierTracker';

export default {
	data: function() {
		const data = Object.assign({}, gon.encounter_data, {
			orderInd: 0,
			objectInsts: [],
			subjectInsts: [],
			focused: true,
		});
		return data;
	},
	mixins: [dynamicFieldListItem],
	track: ['has_barrier'],
	components: {
		'contact-field-section': encounterContactFieldSection,
		'barrier-input': encounterContactBarrier,
	},
	methods: {
		setContact(sourceEvent) {
			if (this.state.setContact()) {
				this.touchInput('possible_contact_id');
			}
			this.touchInput(sourceEvent);
			this.updateBarriers(false);
		},
		touchInput(field) {
			if (!this.$v || !this.$v[field]) { return; }
			this.$v[field].$touch();
		},
		updateBarriers(touch) {
			if (touch) {
				this.touchInput('barriers');
			}
			this.$emit('track');
		},
		blur() {
			this.focused = false;
			this.$v.$touch();
		},
		focus() {
			this.focused = true;
		},
		getFirstInput() {
			return this.$el.querySelector(':checked');
		},
		onKeyChange() {},
	},
	mounted: function() {
		this.$parent.$emit('should-validate', 'contacts', {
			tooShort: minLength(1),
			$each: {
				subject: {blank: requiredUnless('_destroy')},
				object: {blank: requiredUnless('_destroy')},
				position: {blank: requiredUnless('_destroy')},
				possible_contact_id: {blank: requiredUnless('_destroy')},
				barriers: {}
			}
		});

		this.$emit('start-tracking', (list) => new EncounterBarrierTracker(list, this.possibles));
	},
};
</script>
