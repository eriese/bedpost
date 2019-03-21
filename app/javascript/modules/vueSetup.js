import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import Vuelidate from 'vuelidate';

import _root from "@components/Root";
import nav from '@components/NavComponent'

import basicStepper from '@components/stepper/BasicStepperComponent';
import formStepper from "@components/stepper/FormStepperComponent.vue"
import formStep from "@components/stepper/FormStepComponent.vue"

import vuelidateForm from '@components/form/VuelidateFormComponent';
import fieldErrors from "@components/form/FieldErrorsComponent.vue"
import formErrors from "@components/form/FormErrorsComponent.vue"
import toggle from "@components/form/ToggleComponent.vue"
import encounterContactField from "@components/form/EncounterContactField.vue"
import dynamicFieldList from "@components/form/DynamicFieldList.vue";

import arrowButton from "@components/functional/ArrowButton";


/**
 * Register all vue components and set up the Vue instance
 * @module vueSetup
 */
export default function addVue() {
	Vue.use(TurbolinksAdapter);
	Vue.use(Vuelidate);
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

	Vue.component('arrow-button', arrowButton);

	return new Vue(_root);
}
