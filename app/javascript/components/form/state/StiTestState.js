import BaseState from '@components/form/state/BaseState';

export default class StiTestState extends BaseState {
	constructor(tst, vm, baseName, index) {
		super(tst, vm, baseName, index);
		this.formData = vm.formData;
		this._vm = vm;
	}

	get tested_on() {
		return this.formData.tested_on;
	}

	get submissionError() {
		return this._vm.submissionError && this._vm.submissionError[this.item.tested_for_id];
	}
}
