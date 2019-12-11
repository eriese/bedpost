import { validateWithServer } from '@modules/validators';
import axios from 'axios';
import { helpers } from 'vuelidate/lib/validators';
jest.mock('axios');
jest.mock('vuelidate/lib/validators');

helpers.withParams.mockImplementation((params, validator) => {
	return {params, validator};
});

describe('custom validators', () => {
	describe('validateWithServer', () => {
		beforeAll(() => {
			jest.useFakeTimers();
		});

		afterAll(() => {
			jest.useRealTimers();
		});

		afterEach(() => {
			axios.get.mockClear();
		});

		const detail = 'error details';
		const getMessage = () => new Promise((resolve) => {
			resolve({
				data: {field1: detail}
			});
		});
		const getTrue = () => new Promise((resolve) => {
			resolve({data: true});
		});

		it ('adds the request error as the responseMessage parameter in $v', () => {

			axios.get.mockImplementationOnce(getMessage);

			const {validator, params} = validateWithServer('field1', 'some/url');
			const promise = validator('some value').then(() => {
				expect(params.responseMessage.message).toEqual(detail);
			});
			jest.runAllTimers();
			return promise;
		});

		it('returns false if json data is returned', () => {
			axios.get.mockImplementationOnce(getMessage);

			const {validator} = validateWithServer('field1', 'some/url');
			const promise = validator('some value').then((response) => {
				expect(response).toBe(false);
			});

			jest.runAllTimers();
			return promise;
		});

		it('returns true if the value is empty', () => {
			const {validator} = validateWithServer('field1', 'some/url');
			const response = validator('');
			expect(response).toBe(true);
		});

		it('returns true if the value is null', () => {
			const {validator} = validateWithServer('field1', 'some/url');
			const response = validator(null);
			expect(response).toBe(true);
		});

		it('returns true if the request returns true', () => {
			axios.get.mockImplementationOnce(getTrue);

			const {validator} = validateWithServer('field1', 'some/url');
			const promise = validator('some value').then((response) => {
				expect(response).toBe(true);
			});

			jest.runAllTimers();
			return promise;
		});

		it('resets the message before running again', async () => {
			const {params, validator} = validateWithServer('field1', 'some/url');
			axios.get.mockImplementationOnce(getMessage);
			validator('some value');
			jest.runAllTimers();
			await Promise.resolve();

			expect(params.responseMessage.message).toEqual(detail);
			validator('some other value');
			expect(params.responseMessage.message).toEqual('');
		});

		it('waits 1000ms to send the request', () => {
			const {validator} = validateWithServer('field1', 'some/url');
			axios.get.mockImplementation(getTrue);
			const promise = validator('some value');

			jest.advanceTimersByTime(999);
			expect(axios.get).not.toHaveBeenCalled();
			jest.advanceTimersByTime(1);
			expect(axios.get).toHaveBeenCalled();

			return promise;
		});

		it('debounces sending the request', () => {
			const {validator} = validateWithServer('field1', 'some/url');
			axios.get.mockImplementation(getTrue);
			validator('some value');

			jest.advanceTimersByTime(999);
			expect(axios.get).not.toHaveBeenCalled();

			const promise = validator('some new value');
			jest.advanceTimersByTime(1);
			expect(axios.get).not.toHaveBeenCalled();

			jest.advanceTimersByTime(1000);
			expect(axios.get).toHaveBeenCalled();
			return promise;
		});
	});
});
