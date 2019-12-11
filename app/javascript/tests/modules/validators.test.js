import { validateWithServer } from '@modules/validators';
import Vuelidate from 'vuelidate';
import {mount, createLocalVue} from '@vue/test-utils';
import axios from 'axios';
jest.mock('axios');
jest.useFakeTimers();

describe('custom validators', () => {
	describe('validateWithServer', () => {
		it ('adds the promise error as the responseMessage parameter in $v', () => {

			const localVue = createLocalVue();
			localVue.use(Vuelidate);

			const wrapper = mount({
				template: '<div><input v-model="field1"/></div>',
				data() {
					return {
						field1: null,
					};
				},
				validations: {
					field1: {
						onServer: validateWithServer('field1', 'someUrl'),
					}
				}
			}, {localVue});

			const detail = 'error details';
			axios.get.mockImplementationOnce(function() {
				return new Promise((resolve) => {
					resolve({
						data: {field1: detail}
					});
				});
			});

			wrapper.find('input').setValue('anything');
			return wrapper.vm.$nextTick().then(() => {
				const vField = wrapper.vm.$v.field1;
				console.log(vField.$touch());
				expect(vField.$pending).toEqual(false);
			});

		});
	});
});
