export default {
	isAlias(id, instrument, instruments) {
		return instrument.alias_of_id == id || instruments[id].alias_of_id == instrument._id;
	}
};
