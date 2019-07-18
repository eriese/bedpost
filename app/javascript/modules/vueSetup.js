import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import Vuelidate from 'vuelidate';
import VCalendar from 'v-calendar';

import _root from "@components/Root";
import nav from '@components/NavComponent'

import basicStepper from '@components/stepper/BasicStepperComponent';
import formStepper from "@components/stepper/FormStepperComponent.vue"
import formStep from "@components/stepper/FormStepComponent.vue"

import vuelidateForm from '@components/form/VuelidateFormComponent';
import fieldErrors from "@components/form/FieldErrorsComponent.vue"
import formErrors from "@components/form/FormErrorsComponent.vue"
import toggle from "@components/form/ToggleComponent.vue"
import dynamicFieldList from "@components/form/DynamicFieldList.vue";

import encounterContactField from "@components/form/encounter/EncounterContactField.vue"

import dropDown from "@components/display/DropDown.vue";
import progBar from "@components/display/ProgBar.vue";
import bubble from "@components/display/Bubble.vue"

import arrowButton from "@components/functional/ArrowButton";

import encounterCalendar from '@components/widgets/encounterCalendar/EncounterCalendar.vue';


/**
 * Register all vue components and set up the Vue instance
 * @module vueSetup
 */
export default function addVue() {
	Vue.use(TurbolinksAdapter);
	Vue.use(Vuelidate);
	Vue.use(VCalendar);
	Vue.component('nav-component', nav);
	Vue.component('vuelidate-form', vuelidateForm);
	Vue.component('basic-stepper', basicStepper);

	Vue.component('field-errors', fieldErrors);
	Vue.component('form-errors', formErrors);
	Vue.component('toggle', toggle);
	Vue.component('form-stepper', formStepper);
	Vue.component('form-step', formStep);
	Vue.component('encounter-contact-field', encounterContactField);
	Vue.component('dynamic-field-list', dynamicFieldList);

	Vue.component('drop-down', dropDown);
	Vue.component('prog-bar', progBar);
	Vue.component('bubble', bubble);

	Vue.component('arrow-button', arrowButton);

	Vue.component('encounter-calendar', encounterCalendar);

	return new Vue(_root);
}
