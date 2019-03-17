<template>
<div class="contact-field">
	<div class="field-section">
		<div>
			<input type="radio" value="self" v-model="subj" id="self_first">
			<label for="self_first">{{$root.t("I")}}</label>
		</div>
		<div>
			<input type="radio" value="partner" v-model="subj" id="partner_first">
			<label for="partner_first">{{partnerPronoun.subject}}</label>
		</div>
	</div>
	<div class="field-section">
		<div v-for="c in possibleContacts">
			<input type="radio" :name="`${baseName}[contact_type]`" :value="c.key" :id="c.key" v-model="value.contact_type">
			<label :for="c.key">{{$root.t(`contact.contact_type.${c.t_key}`)}}</label>
		</div>
	</div>
	<div class="field-section">
		<div>
			<input type="radio" value="partner" v-model="obj" id="partner_obj">
			<label for="partner_obj">{{partnerPronoun.possessive}}</label>
		</div>
		<div>
			<input type="radio" value="self" v-model="obj" id="self_obj">
			<label for="self_obj">{{$root.t("my")}}</label>
		</div>
	</div>
	<div class="field-section">
		<div v-for="oi in objInsts">
			<input type="radio" :name="`${baseName}[${actorOrder[0]}_instrument_id]`" v-model="value[actorOrder[0] + '_instrument_id']" :value="oi._id" :id="`${baseID}${actorOrder[0]}_instrument_${oi._id}`">
			<label :for="`${baseID}${actorOrder[0]}_instrument_${oi._id}`">{{oi[`${obj}_name`]}}</label>
		</div>
	</div>
	<div class="field-section">{{$root.t("contact.with", {pronoun: subj == "self" ? $root.t("my") : partnerPronoun.possessive})}}</div>
	<div class="field-section">
		<div v-for="si in subjInsts">
			<input type="radio" :name="`${baseName}[${actorOrder[1]}_instrument_id]`" :value="si.id" :v-model="`value['${subj}_instrument_id']`" :id="`${baseID}${actorOrder[1]}_instrument_${si._id}`">
			<label :for="`${baseID}${actorOrder[1]}_instrument_${si._id}`">{{si[`${subj}_name`]}}</label>
		</div>
	</div>
</div>

</template>

<script>
	const base_matcher = /^(?!.*[_](by|self|partner)$).*$/
	const self_matcher = /^(?!.*_by).*_self$/
	const partner_matcher = /^(?!.*_by).*_partner$/

	const _orders = [["self", "partner"],["partner", "self"]]
	const _keys = [["inverse_inst", "inst_key"], ["inst_key", "inverse_inst"]]

	export default {
		data: function() {
			let origContact = gon.encounter_data.contacts[this.value.contact_type]
			return {
				partnerPronoun: gon.encounter_data.partnerPronoun,
				instruments: gon.encounter_data.instruments,
				subj: origContact.subject,
				obj: origContact.object
			}
		},
		props: ['value', 'baseName'],
		computed: {
			possibleContacts: function() {
				let contacts = []
				let isSelf = this.isSelf
				for(let k in gon.encounter_data.contacts) {
					let con = gon.encounter_data.contacts[k]
					if ((con.subject == this.subj && con.object == this.obj
						&& (!isSelf || !con.key.match(/_by/)))
						|| (!isSelf && !con.subject && !con.object)) {
						contacts.push(con)
					}
				}
				return contacts
			},
			objInsts: function() {
				return this.getObjInsts();
			},
			subjInsts: function() {
				return this.getSubjInsts();
			},
			baseID: function() {
				return this.baseName.replace(/[\[\]\.]/g, "_")
			},
			cType: function() {
				return gon.encounter_data.contacts[this.value.contact_type]
			},
			orderInd: function() {
				return this.isSelf || this.subj == "self" ? 0 : 1
			},
			actorOrder: function() {
				return _orders[this.orderInd];
			},
			isSelf: function() {
				return this.subj == this.obj;
			}
		},
		watch: {
			possibleContacts: function() {
				let res = this.value.contact_type.replace(/(_self|_partner|_by)/, "");
				for (let i = 0; i < this.possibleContacts.length; i++) {
					let con = this.possibleContacts[i];
					if (con.key.match(res)) {
						this.value.contact_type = con.key
						return
					}
				}
			}
		},
		methods: {
			getPossibleContacts(subj, obj) {
				let contacts = [];

				return contacts;
			},
			getObjInsts() {
				return Object.values(gon.encounter_data.instruments).filter(this.instsToShow(false));
			},
			getSubjInsts() {
				let actor = this.actorOrder[0];
				let objInstId = this.value[`${actor}_instrument_id`];
				if (!objInstId) {
					return [];
				}

				let objInst = gon.encounter_data.instruments[objInstId];
				let instKey = this.cType[actor == "self" ? "inverse_inst" : "inst_key"] + "_ids"
				let filter = this.instsToShow(true)

				let ret_insts = [];
				let usedKeys = {};
				let insts = objInst[instKey]
				for (var i = 0; i < insts.length; i++) {
					let instId = insts[i]
					if (usedKeys[instId]) {continue;}
					usedKeys[instId] = true
					let inst = gon.encounter_data.instruments[instId]
					if (filter(inst)) {
						ret_insts.push(inst)
					}
				}

				return ret_insts;
			},
			instsToShow(forSubj) {
				let conditionKey = this.cType[_keys[this.orderInd][forSubj ? 1 : 0]]
				// || (!forSubj && this.actorOrder[0] == "partner") ? this.cType.inst_key : this.cType.inverse_inst;
				let contactKey = conditionKey + "_ids";
				let checkUser = forSubj ? this.subj : this.obj;
				return (inst) => {
					if (inst[contactKey].length == 0) {return false;}
					if (inst.conditions == null) {return true;}
					let conditions = inst.conditions.all || inst.conditions[conditionKey];
					if (conditions == undefined && this.isSelf) {
						conditions = inst.conditions[conditionKey.replace("_" + this.subj, "")]
					}
					if(conditions == undefined) {return true;}
					for (var i = 0; i < conditions.length; i++) {
						if (!gon.encounter_data[checkUser][conditions[i]]) {
							return false;
						}
					}
					return true;
				}
			}
		}
	}
</script>
