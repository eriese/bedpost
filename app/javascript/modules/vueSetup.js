import Vue from 'vue';
import TurbolinksAdapter from 'vue-turbolinks';
import Vuelidate from 'vuelidate';
import VCalendar from 'v-calendar';

import vSelect from 'vue-select';

import bedpostVueGlobals from '@plugins/bedpostVueGlobals';
import tourguide from '@plugins/tourguide';
import analytics from '@plugins/analytics';

import _root from "@components/Root";
import nav from '@components/NavComponent';

const formStepper = () => import (
	/* webpackChunkName: "components/form-stepper", webpackMode: "lazy", webpackPreload: true */ "@components/stepper/FormStepperComponent.vue");
const formStep = () => import (
	/* webpackChunkName: "components/form-stepper", webpackMode: "lazy", webpackPreload: true */ "@components/stepper/FormStepComponent.vue");
const basicStepper = () => import(/* webpackChunkName: "components/basic-stepper", webpackPreload: true */ '@components/stepper/BasicStepperComponent');

const vuelidateForm = () => import (/* webpackChunkName: "components/form", webpackPreload: true */ '@components/form/VuelidateFormComponent');
const fieldErrors = () => import (/* webpackChunkName: "components/form", webpackPreload: true */ "@components/form/FieldErrorsComponent.vue");
const formErrors = () => import (/* webpackChunkName: "components/form", webpackPreload: true */ "@components/form/FormErrorsComponent.vue");
const toggle = () => import (/* webpackChunkName: "components/toggle", webpackPreload: true */ "@components/form/ToggleComponent.vue");
const fileInput = () => import (/* webpackChunkName: "components/file-input", webpackPreload: true */ '@components/form/FileInput.vue');
const dynamicFieldList = () => import (/* webpackChunkName: "components/dynamic-field-list", webpackPreload: true */ "@components/form/DynamicFieldList.vue");

const encounterContactField = () => import (/* webpackChunkName: "components/encounter-contact-field", webpackPreload: true */ "@components/form/encounter/EncounterContactField.vue");
const stiTestInput = () => import (/* webpackChunkName: "conponents/sti-test-input", webpackPreload: true */ '@components/form/StiTestInput.vue');

const dropDown = () => import (/* webpackChunkName: "components/dropdown", webpackPreload: true */ "@components/display/DropDown.vue");
const progBar = () => import (/* webpackChunkName: "components/prog-bar", webpackPreload: true */ "@components/display/ProgBar.vue");
const bubble = () => import (/* webpackChunkName: "components/bubble", webpackPreload: true */ "@components/display/Bubble.vue")
const contentRequester = () => import (/* webpackChunkName: "components/content-requester", webpackPreload: true */ "@components/display/ContentRequester.vue");
const toggleSwitch = () => import (/* webpackChunkName: "components/toggle-switch", wepbackPreload: true */ "@components/display/ToggleSwitch.vue");

const arrowButton = () => import (/* webpackChunkName: "components/arrow-button", webpackPreload: true */ "@components/functional/ArrowButton");


const partnershipChart = () => import(/* webpackChunkName: "components/radar-chart", webpackPreload: true */ "@components/widgets/PartnershipChart.js");
const encounterCalendar = () => import (/* webpackChunkName: "components/encounter-calendar", webpackPreload: true */ '@components/widgets/EncounterCalendar.vue');
const calendarExplainer = () => import(/* webpackChunkName: "components/CalendarExplainer", webpackPreload: true */ '@components/display/CalendarExplainer.vue')

const Tooltip = () => import(/* webpackChunkName: "components/tooltip", webpackPreload: true */ '@components/form/Tooltip.vue');


/**
 * Register all vue components and set up the Vue instance
 * @module vueSetup
 */
export default function addVue() {
	Vue.use(TurbolinksAdapter);
	Vue.use(Vuelidate);
	Vue.use(VCalendar);
	Vue.use(bedpostVueGlobals);
	Vue.use(tourguide);
	Vue.use(analytics);

	Vue.component('v-select', vSelect);

	Vue.component('nav-component', nav);
	Vue.component('vuelidate-form', vuelidateForm);
	Vue.component('basic-stepper', basicStepper);

	Vue.component('field-errors', fieldErrors);
	Vue.component('form-errors', formErrors);
	Vue.component('toggle', toggle);
	Vue.component('file-input', fileInput);
	Vue.component('form-stepper', formStepper);
	Vue.component('form-step', formStep);
	Vue.component('encounter-contact-field', encounterContactField);
	Vue.component('sti-test-input', stiTestInput);
	Vue.component('dynamic-field-list', dynamicFieldList);

	Vue.component('drop-down', dropDown);
	Vue.component('prog-bar', progBar);
	Vue.component('bubble', bubble);
	Vue.component('content-requester', contentRequester);
	Vue.component('toggle-switch', toggleSwitch);

	Vue.component('arrow-button', arrowButton);

	Vue.component('encounter-calendar', encounterCalendar);
	Vue.component('partnership-chart', partnershipChart);
	Vue.component('calendar-explainer', calendarExplainer);
	Vue.component('tooltip', Tooltip);

	return new Vue(_root);
}
