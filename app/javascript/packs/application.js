/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb
import TurbolinksAdapter from 'vue-turbolinks'
import Vue from 'vue/dist/vue.esm'
import Vuelidate from 'vuelidate';
import {addTransitionEvents} from '@modules/transitions';
import addTurbolinksFixes from '@modules/turbolinksFixes';

import navComponent from '@components/NavComponent'
import vuelidateFormComponent from '@components/form/VuelidateFormComponent';
import basicStepperComponent from '@components/stepper/BasicStepperComponent';
import fieldErrors from "@components/form/FieldErrorsComponent.vue"
import formErrors from "@components/form/FormErrorsComponent.vue"
import toggle from "@components/form/ToggleComponent.vue"
import formStepper from "@components/stepper/FormStepperComponent.vue"
import formStep from "@components/stepper/FormStepComponent.vue"
import root from "@components/Root";

import Rails from "@rails/ujs";

Rails.start();

addTurbolinksFixes();
addTransitionEvents();

// set up vue
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
let app = null;
document.addEventListener('turbolinks:load', () => {
	// remove no-js specific styling
	let classList = document.getElementById("vue-container").classList;
	classList.remove("no-js");
	classList.add("with-js");

	app = new Vue(root)

	Rails.confirm = app.isConfirmed
});
