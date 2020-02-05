export default class BaseState {
	constructor(item, vm) {
		this.item = item;
		this.$_t = vm.$_t;
	}

	get baseName() {
		return `${this._baseName}[${this.index}]`;
	}
	set baseName(newName) {
		this._baseName = newName;
	}
	get index() {
		return this._index;
	}
	set index(newIndex) {
		this._index = newIndex;
	}
}
