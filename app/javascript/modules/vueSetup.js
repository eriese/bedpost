import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import Vuelidate from 'vuelidate';

import navComponent from '@components/NavComponent'
import vuelidateFormComponent from '@components/form/VuelidateFormComponent';
import basicStepperComponent from '@components/stepper/BasicStepperComponent';
import fieldErrors from "@components/form/FieldErrorsComponent.vue"
import formErrors from "@components/form/FormErrorsComponent.vue"
import toggle from "@components/form/ToggleComponent.vue"
import formStepper from "@components/stepper/FormStepperComponent.vue"
import formStep from "@components/stepper/FormStepComponent.vue"
import EncounterContactField from "@components/form/EncounterContactField.vue"
import _root from "@components/Root";

/**
 * Register all vue components and set up the Vue instance
 * @module vueSetup
 */
export default function addVue() {
	Vue.use(TurbolinksAdapter);
	Vue.use(Vuelidate);
	Vue.component('nav-component', navComponent);
	Vue.component('vuelidate-form', vuelidateFormComponent);
	Vue.component('basic-stepper', basicStepperComponent);

	Vue.component('field-errors', fieldErrors);
	Vue.component('form-errors', formErrors);
	Vue.component('toggle', toggle);
	Vue.component('form-stepper', formStepper);
	Vue.component('form-step', formStep);
	Vue.component('encounter-contact-field', EncounterContactField);

	return new Vue(_root);
}
