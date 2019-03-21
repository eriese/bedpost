<template>
<div class="contact-field-container">
	<div class="contact-field">
		<div class="field-section narrow">
			<div>
				<input type="radio" class="mini" value="self" v-model="subj" :id="`${baseID}_self_subj`" @change="changeActorOrder" :name="`${baseName}[subj]`">
				<label :for="`${baseID}_self_subj`">{{$root.t("I")}}</label>
			</div>
			<div>
				<input type="radio" class="mini" value="partner" v-model="subj" :id="`${baseID}_partner_subj`" @change="changeActorOrder" :name="`${baseName}[subj]`">
				<label :for="`${baseID}_partner_subj`">{{partnerPronoun.subject}}</label>
			</div>
		</div>
		<div class="field-section narrow">
			<div v-for="c in possibleContacts">
				<input type="radio" class="mini" :name="`${baseName}[contact_type]`" :value="c.key" v-inst="_value.contact_type" :id="`${baseID}_${c.key}`" v-model="_value.contact_type" @change="resetInsts">
				<label :for="`${baseID}_${c.key}`">{{$root.t(`contact.contact_type.${c.t_key}`)}}</label>
			</div>
		</div>
		<div class="field-section narrow">
			<div>
				<input type="radio" class="mini" value="partner" v-model="obj" :id="`${baseID}_partner_obj`" @change="changeActorOrder" :name="`${baseName}[obj]`">
				<label :for="`${baseID}_partner_obj`">{{partnerPronoun.possessive}}</label>
			</div>
			<div>
				<input type="radio" class="mini" value="self" v-model="obj" :id="`${baseID}_self_obj`" @change="changeActorOrder" :name="`${baseName}[obj]`">
				<label :for="`${baseID}_self_obj`">{{$root.t("my")}}</label>
			</div>
		</div>
		<div class="field-section">
			<div v-for="oi in objInsts">
				<input type="radio" class="mini" :name="`${baseName}[${actorOrder[1]}_instrument_id]`" v-inst="objInst" v-model="objInst" :value="oi._id" :id="`${baseID}${actorOrder[1]}_instrument_${oi._id}`" @change="resetInsts(true)">
				<label :for="`${baseID}${actorOrder[1]}_instrument_${oi._id}`">{{oi[`${obj}_name`]}}</label>
			</div>
		</div>
		<div class="field-section narrow">
			<p v-html="subjPossessive"></p>
		</div>
		<div class="field-section">
			<div v-if="subjInsts.length">
				<div v-for="si in subjInsts">
					<input type="radio" class="mini" :name="`${baseName}[${actorOrder[0]}_instrument_id]`" v-inst="subjInst" v-model="subjInst" :value="si._id" :id="`${baseID}${actorOrder[0]}_instrument_${si._id}`">
					<label :for="`${baseID}${actorOrder[0]}_instrument_${si._id}`">{{si[`${subj}_name`]}}</label>
				</div>
			</div>
		</div>
	</div>
	<div class="contact-barriers clear-fix">
		<div>{{$root.t("contact.with", {pronoun: ""})}}</div>
		<div>
			<div v-for="(bType, bKey) in barriers" v-show="!bType.condition || value[bType.condition]">
				<input type="checkbox" v-model="_value.barriers" :name="`${baseName}[barriers][]`" :id="`${baseID}_barriers_${bKey}`" :value="bKey" @change="onInput">
				<label :for="`${baseID}_barriers_${bKey}`">{{$root.t(bKey, {scope: "contact.barrier", partner_instrument: partnerName, self_instrument: selfName})}}</label>
			</div>
		</div>
	</div>
</div>
</template>

<script>
	import dynamicFieldListItem from "@mixins/dynamicFieldListItem"

	const _orders = [["self", "partner"], ["partner", "self"]]
	const _keys = [["inverse_inst", "inst_key"], ["inst_key", "inverse_inst"]]

	export default {
		data: function() {
			return Object.assign({}, gon.encounter_data, {
				subj: null,
				obj: null,
				orderInd: 0,
				objInsts: [],
				subjInsts: [],
				onKeyChange: false
			})
		},
		mixins: [dynamicFieldListItem],
		computed: {
			possibleContacts: function() {
				let contacts = []
				let isSelf = this.isSelf
				let curContact = this._value.contact_type.replace(/(_self|_partner|_by)/, "");
				for(let k in this.contacts) {
					let con = this.contacts[k]
					if ((con.subject == this.subj && con.object == this.obj
						&& (!isSelf || !con.key.match(/_by/)))
						|| (!isSelf && !con.subject && !con.object)) {
						contacts.push(con)
					}
				}
				return contacts
			},
			baseID: function() {
				return this.baseName.replace(/[\[\]\.]/g, "_")
			},
			cType: function() {
				return this.contacts[this.value.contact_type]
			},
			actorOrder: function() {
				return _orders[this.orderInd];
			},
			isSelf: function() {
				return this.subj == this.obj;
			},
			partnerName: function() {
				let p_inst_id = this.value.partner_instrument_id
				return p_inst_id ? this.instruments[p_inst_id].partner_name : ""
			},
			selfName: function() {
				let s_inst_id = this.value.self_instrument_id
				return s_inst_id ? this.instruments[s_inst_id].self_name : ""
			},
			subjPossessive: function() {
				if (!this.subjInsts.length) {return ". . ."}
				return this.$root.t("contact.with", {pronoun: "<br>" + (this.subj == "self" ? this.$root.t("my") : this.partnerPronoun.possessive)})
			},
			objInst: {
				get: function() {
					return this.value[this.actorOrder[1] + '_instrument_id']
				},
				set: function(newVal) {
					this._value[this.actorOrder[1] + '_instrument_id'] = newVal;
					this.onInput();
				}
			},
			subjInst: {
				get: function() {
					return this.value[this.actorOrder[0] + '_instrument_id']
				},
				set: function(newVal) {
					this._value[this.actorOrder[0] + '_instrument_id'] = newVal;
					this.onInput();
				}
			}
		},
		methods: {
			resetInsts(e) {
				if (e) {this.onInput();}

				this.$nextTick(() => {
					let lst = e === true? ['subjInst'] : ['objInst', 'subjInst']
					for (var s = 0; s < lst.length; s++) {
						let actorKey = lst[s];
						let instId = this[actorKey];
						let lstId = actorKey + "s";
						let newList = this["get" + lstId.slice(0,1).toUpperCase() + lstId.slice(1)]();
						if (newList.filter((i) => i._id == instId).length == 0) {
							this[actorKey] = null;
						}
						this[lstId] = newList
					}
				})
			},
			getObjInsts() {
				return Object.values(this.instruments).filter(this.instsToShow(false));
			},
			getSubjInsts() {
				if (!this.objInst) {
					return [];
				}

				let objInst = this.instruments[this.objInst];
				let instKey = this.cType[_keys[this.orderInd][0]] + "_ids"
				let filter = this.instsToShow(true)

				let ret_insts = [];
				let insts = objInst[instKey]
				for (var i = 0; i < insts.length; i++) {
					let inst = this.instruments[insts[i]];
					if (filter(inst)) {
						ret_insts.push(inst);
					}
				}

				return ret_insts;
			},
			instsToShow(forSubj) {
				let conditionKey = this.cType[_keys[this.orderInd][forSubj ? 1 : 0]]
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
						if (!this[checkUser][conditions[i]]) {
							return false;
						}
					}
					return true;
				}
			},
			changeActorOrder(event, isInit) {
				let oldOrder = this.actorOrder

				if (isInit) {
					let origContact = this.contacts[this.value.contact_type]
					this.subj = origContact.subject || oldOrder[0]
					this.obj = origContact.object || oldOrder[1]
				}

				let newInd = this.subj == this.obj || this.subj == "self" ? 0 : 1;
				if (newInd != this.orderInd) {
					this.orderInd = newInd;

					if (!isInit) {
						let oldSubjInst = this._value[oldOrder[0] + "_instrument_id"]
						let oldObjInst = this._value[oldOrder[1] + "_instrument_id"]

						this._value[this.actorOrder[0] + "_instrument_id"] = oldSubjInst;
						this._value[this.actorOrder[1] + "_instrument_id"] = oldObjInst;

						this.onInput()
					}
				}

				this.updateContactType();
			},
			updateContactType() {
				let res = this._value.contact_type.replace(/(_self|_partner|_by)/g, "");
				for (let i = 0; i < this.possibleContacts.length; i++) {
					let con = this.possibleContacts[i];
					if (con.key.match(res)) {
						this._value.contact_type = con.key;
						this.onInput();
						this.resetInsts()
						return;
					}
				}
			},

			onInput() {
				this.$emit("input", this._value);
			}
		},
		directives: {
			'inst': {
				update: function(el, binding, vnode) {
					if (Object.getAtPath(vnode.context, binding.expression) == el._value) {
						el.checked = true;
					}
				}
			}
		},
		mounted: function() {
			this.changeActorOrder(null, true);
		}
	}
</script>
