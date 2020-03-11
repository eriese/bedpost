import BaseState from '@components/form/state/BaseState';

export default class StiTestState extends BaseState {
	constructor(tst, vm, baseName, index) {
		super(tst, vm, baseName, index);
		this.formData = vm.formData;
	}

	get tested_on() {
		return this.formData.tested_on;
	}
}
