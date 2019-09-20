import Vue from 'vue/dist/vue.esm';
import TurbolinksAdapter from 'vue-turbolinks';
import Vuelidate from 'vuelidate';
import VCalendar from 'v-calendar';
import vSelect from 'vue-select';

import bedpostVueGlobals from '../plugins/bedpostVueGlobals';

import _root from "@components/Root";
import nav from '@components/NavComponent'


const formStepper = () => import (
	/* webpackChunkName: "components.form-stepper", webpackMode: "lazy" */ "@components/stepper/FormStepperComponent.vue");
const formStep = () => import (
	/* webpackChunkName: "components.form-stepper", webpackMode: "lazy" */ "@components/stepper/FormStepComponent.vue");
const basicStepper = () => import(/* webpackChunkName: "components.basic-stepper" */ '@components/stepper/BasicStepperComponent');

const vuelidateForm = () => import (/* webpackChunkName: "components.form" */ '@components/form/VuelidateFormComponent');
const fieldErrors = () => import (/* webpackChunkName: "components.form" */ "@components/form/FieldErrorsComponent.vue");
const formErrors = () => import (/* webpackChunkName: "components.form" */ "@components/form/FormErrorsComponent.vue");
const toggle = () => import (/* webpackChunkName: "components.toggle" */ "@components/form/ToggleComponent.vue");
const dynamicFieldList = () => import (/* webpackChunkName: "components.dynamic-field-list" */ "@components/form/DynamicFieldList.vue");

const encounterContactField = () => import (/* webpackChunkName: "components.encounter-contact-field" */ "@components/form/encounter/EncounterContactField.vue");

const dropDown = () => import (/* webpackChunkName: "components.dropdown" */ "@components/display/DropDown.vue");
const progBar = () => import (/* webpackChunkName: "components.prog-bar" */ "@components/display/ProgBar.vue");
const bubble = () => import (/* webpackChunkName: "bubble" */ "@components/display/Bubble.vue")

const arrowButton = () => import (/* webpackChunkName: "components.arrow-button" */ "@components/functional/ArrowButton");

const encounterCalendar = () => import (/* webpackChunkName: "components.encounter-calendar" */ '@components/widgets/encounterCalendar/EncounterCalendar.vue');



/**
 * Register all vue components and set up the Vue instance
 * @module vueSetup
 */
export default function addVue() {
	Vue.use(TurbolinksAdapter);
	Vue.use(Vuelidate);
	Vue.use(VCalendar);
	Vue.use(bedpostVueGlobals);

	Vue.component('v-select', vSelect);

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
