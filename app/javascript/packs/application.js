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
import navComponent from '../components/navComponent'
import vuelidateFormComponent from '../components/vuelidateFormComponent';
import VueResource from 'vue-resource';
import {animIn} from './transitions';

Vue.use(TurbolinksAdapter);
Vue.use(Vuelidate);
Vue.use(VueResource);
Vue.component('nav-component', navComponent);
Vue.component('vuelidate-form', vuelidateFormComponent);
let app = null;
let animLength = 0.2;
document.addEventListener('turbolinks:load', () => {
	// remove no-js specific styling
	document.getElementById("vue-container").classList.remove("no-js")
	app = new Vue({
		el: '#vue-container',
		mounted: animIn
	})
});
