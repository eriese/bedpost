<template>
<div class="contact-field-container" :class="{blurred: !focused}">
	<div class="contact-field">
		<div class="field-section narrow">
			<hidden-radio v-for="i in [{labelKey: 'I', inputValue: 'self'}, {label: partnerPronoun.subject, inputValue: 'partner'}]"
				:key="'subj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="subj"
				@change="changeActorOrder">
			</hidden-radio>
		</div>
		<div class="field-section narrow">
			<hidden-radio v-for="c in possibleContacts"
				:key="c.key" v-bind="{
					labelKey: 'contact.contact_type.' + c.t_key,
					inputValue: c.key,
					model: 'contact_type',
					baseName}"
				v-model="_value.contact_type"
				@change="resetInsts">
			</hidden-radio>
		</div>
		<div class="field-section narrow">
			<hidden-radio v-for="i in [{label: partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'self'}]"
				:key="'obj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="obj"
				@change="changeActorOrder">
			</hidden-radio>
		</div>
		<div class="field-section">
			<hidden-radio v-for="oi in objInsts"
				:key="oi._id"
				v-bind="{
					label: oi[obj + '_name'],
					inputValue: oi._id,
					model: actorOrder[1] + '_instrument_id',
					baseName
				}"
				v-model="objInst"
				@change="resetInsts(true)">
			</hidden-radio>
		</div>
		<div class="field-section narrow">
			<p v-html="subjPossessive"></p>
		</div>
		<div class="field-section">
			<div v-if="subjInsts.length > 1">
				<hidden-radio v-for="si in subjInsts"
				:key="si._id"
				v-bind="{
					label: si[subj + '_name'],
					inputValue: si._id,
					model: actorOrder[0] + '_instrument_id',
					baseName
				}"
				v-model="subjInst">
			</hidden-radio>
			</div>
		</div>
	</div>
	<div class="contact-barriers clear-fix">
		<div>{{$root.t("contact.with", {pronoun: ""})}}</div>
		<div>
			<barrier-input v-for="(bType, bKey) in barriers"
				:key="baseName + bKey"
				v-bind="{
					barrier: bType,
					contact: value,
					partnerName,
					selfName,
					baseName,
					encounterData: {has_barrier: tracked.has_barrier, index: watchKey}
				}"
				v-model="_value.barriers"
				@change="updateBarriers">
			</barrier-input>
			<!-- <div v-for="(bType, bKey) in barriers" v-show="!bType.condition || value[bType.condition]">
				<input type="checkbox" v-model="_value.barriers" :name="`${baseName}[barriers][]`" :id="`${baseID}_barriers_${bKey}`" :value="bKey" @change="onInput">
				<label :for="`${baseID}_barriers_${bKey}`">{{$root.t(bKey, {scope: "contact.barrier", partner_instrument: partnerName, self_instrument: selfName})}}</label>
			</div> -->
		</div>
	</div>
</div>
</template>

<script>
	import dynamicFieldListItem from "@mixins/dynamicFieldListItem"
	import hiddenRadio from "./HiddenRadio.vue"
	import encounterContactBarrier from './EncounterContactBarrier.vue'

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
				focused: true,
			})
		},
		mixins: [dynamicFieldListItem],
		track: ["has_barrier"],
		components: {
			"hidden-radio": hiddenRadio,
			"barrier-input": encounterContactBarrier
		},
		watch: {
			'watchKey': function() {
				this.changeActorOrder(null, true);
			}
		},
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

						// let can_contact = false
						// for(let i in this.instruments) {
						// 	if(this.instruments[i][con.inst_key + "_ids"].length) {
						// 		can_contact = true;
						// 		break;
						// 	}
						// }

						// if (can_contact) {
							contacts.push(con)
						// }
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
				if (this.subjInsts.length <= 1) {
					return "";
				}
				return this.$root.t("contact.with", {pronoun: this.subj == "self" ? this.$root.t("my") : this.partnerPronoun.possessive})
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

				let vm = this;
				this.$nextTick(() => {
					let lst = e === true? ['subjInst'] : ['objInst', 'subjInst']
					for (var s = 0; s < lst.length; s++) {
						let actorKey = lst[s];
						let instId = vm[actorKey];
						let lstId = actorKey + "s";
						let newList = vm["get" + lstId.slice(0,1).toUpperCase() + lstId.slice(1)]();
						if (newList.length == 1) {
							vm[actorKey] = newList[0]._id
						}
						else if (newList.filter((i) => i._id == instId).length == 0) {
							vm[actorKey] = null;
						}
						vm[lstId] = newList
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
				let vm = this;
				return (inst) => {
					if (inst[contactKey].length == 0) {return false;}
					if (inst.conditions == null) {return true;}
					let conditions = inst.conditions.all || inst.conditions[conditionKey];
					if (conditions == undefined && vm.isSelf) {
						conditionKey = conditionKey.replace("_self", "");
						conditions = inst.conditions[conditionKey]
					}
					if(conditions == undefined) {return true;}
					for (var i = 0; i < conditions.length; i++) {
						if (!vm[checkUser][conditions[i]]) {
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
				let didMatch = false;
				for (let i = 0; i < this.possibleContacts.length; i++) {
					let con = this.possibleContacts[i];
					if (con.key.match(res)) {
						this._value.contact_type = con.key;
						didMatch = true;
						break;
					}
				}

				if (!didMatch) {
					this._value.contact_type = this.possibleContacts[0].key;
				}
				this.onInput();
				this.resetInsts()
				return;
			},
			updateBarriers(newBarriers) {
				let hadBarriers = this.value.barriers.indexOf("fresh") >=0
				let hasBarriers = newBarriers.indexOf("fresh") >= 0
				if (hadBarriers != hasBarriers) {
					let oldBarriers = this.tracked.has_barrier || 0;
					let change = hasBarriers ? 1 : -1
					this.$emit("track", "has_barrier", oldBarriers + change);
				}
				this.onInput();
			},
			onInput() {
				this.$emit("input", this._value);
			},
			blur() {
				this.focused = false;
			},
			focus() {
				this.focused = true;
			},
			getFirstInput() {
				return this.$el.querySelector(':checked');
			}
		},
		mounted: function() {
			this.changeActorOrder(null, true);
		}
	}
</script>
