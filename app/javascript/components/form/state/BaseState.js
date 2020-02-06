/**
 * A base class for DynamicFieldListItem state
 */
export default class BaseState {
	/**
	 * Create a state instance
	 *
	 * @param  {object} item 			the item to track state for
	 * @param  {Vue} 		vm   			the vue component that uses the state
	 * @param  {string} baseName	the base name of inputs in the list
	 * @param  {number} index			this item's index in the list
	 */
	constructor(item, vm, baseName, index) {
		this.item = item;
		this.$_t = vm.$_t;
		this.baseName = baseName;
		this.index = index;
	}

	/** [baseName description] */
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
