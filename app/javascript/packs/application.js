/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb

import {addTransitionEvents} from '@modules/transitions';
import addTurbolinksFixes from '@modules/turbolinksFixes';
import addVue from '@modules/vueSetup';
import Rails from '@rails/ujs';
import I18nConfig from "@modules/i18n-config";
import axios from 'axios';

Rails.start();

addTurbolinksFixes();
addTransitionEvents();

let app = null;
document.addEventListener('turbolinks:load', async () => {
	// remove no-js specific styling
	let classList = document.getElementById("vue-container").classList;
	classList.remove("no-js");
	classList.add("with-js");

	// add csrf headers to axios
	axios.defaults.headers.common['X-CSRF-Token'] = document
    .querySelector('meta[name="csrf-token"]')
    .getAttribute('content');

	await I18nConfig.setup()
	// set up vue
	app = addVue();

	// hook into the vue instance's confirmation method
	Rails.confirm = app.isConfirmed

});
