<template>
<div class="contact-field-container" :class="{blurred: !focused}">
	<input type="hidden" :value="value._id" :name="baseName + '[_id]'" v-if="!value.newRecord">
	<input type="hidden" :value="value.position" :name="baseName + '[position]'">
	<div class="contact-field">
		<div class="field-section narrow">
			<hidden-radio v-for="i in [{labelKey: 'I', inputValue: 'user'}, {label: partnerPronoun.subject, inputValue: 'partner'}]"
				:key="'subj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.subject"
				model="subject"
				@change="changeActorOrder">
			</hidden-radio>
		</div>
		<div class="field-section narrow">
			<hidden-radio v-for="c in contacts"
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
			<hidden-radio v-for="i in [{label: partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'user'}]"
				:key="'obj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.object"
				model="object"
				@change="changeActorOrder">
			</hidden-radio>
		</div>
		<div class="field-section">
			<hidden-radio v-for="oi in objectInsts"
				:key="oi._id"
				v-bind="{
					label: oi[value.object + '_name'],
					inputValue: oi._id,
					model: 'object_instrument_id',
					baseName
				}"
				v-model="_value.object_instrument_id"
				@change="resetInsts(true)">
			</hidden-radio>
		</div>
		<div class="field-section narrow">
			<p v-html="subjPossessive"></p>
		</div>
		<div class="field-section">
			<div v-show="subjectInsts.length > 1">
				<hidden-radio v-for="si in subjectInsts"
					:key="si._id"
					v-bind="{
						label: si[value.subject + '_name'],
						inputValue: si._id,
						model: 'subject_instrument_id',
						baseName
					}"
					v-model="_value.subject_instrument_id"
					@change="onInput">
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
					encounterData: {has_barrier: tracked.has_barrier, index: watchKey, instruments: instruments}
				}"
				v-model="_value.barriers"
				@change="updateBarriers">
			</barrier-input>
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
				// subj: null,
				// obj: null,
				orderInd: 0,
				objectInsts: [],
				subjectInsts: [],
				focused: true,
				onKeyChange: false
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
				// let curContact = this._value.contact_type.replace(/_self/, "");
				for(let k in this.contacts) {
					let con = this.contacts[k]
					if (!!con.key.match(/_self$/) == this.isSelf) {

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
				return this._value.subject == this._value.object;
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
				if (this.subjectInsts.length <= 1) {
					return "";
				}
				return this.$root.t("contact.with", {pronoun: this.value.subject == "user" ? this.$root.t("my") : this.partnerPronoun.possessive})
			}
		},
		methods: {
			resetInsts(e) {
				if (e) {this.onInput();}

				let vm = this;
				this.$nextTick(() => {
					let lst = e === true ? ['subject'] : ['object', 'subject']
					for (var s = 0; s < lst.length; s++) {
						let actorKey = lst[s];
						let instId = actorKey + '_instrument_id'
						let lstId = actorKey + "Insts";
						let newList = vm[lstId + "Get"]();
						if (newList.length == 1) {
							vm._value[instId] = newList[0]._id
						}
						else if (newList.filter((i) => i._id == vm.value[instId]).length == 0) {
							vm._value[instId] = null;
						}
						vm[lstId] = newList
					}
					this.onInput();
				})
			},
			objectInstsGet() {
				// return Object.values(this.instruments).filter(this.instsToShow(false));
				return this.instsGet(false);
			},
			subjectInstsGet() {
				if (!this.value.object_instrument_id) {
					return [];
				}

				return this.instsGet(true);

				// let objInst = this.instruments[this.value.object_instrument_id];
				// let instKey = this.getConditionKey(false);
				// let filter = this.instsToShow(true)

				// let ret_insts = [];
				// let insts = objInst[instKey]
				// for (var i = 0; i < insts.length; i++) {
				// 	let inst = this.instruments[insts[i]];
				// 	if (filter(inst)) {
				// 		ret_insts.push(inst);
				// 	}
				// }

				// return ret_insts;
			},
			getConditionKey(forSubj) {
				let conditionKey = this.cType[forSubj ? 'inst_key' : 'inverse_inst']
				if (this.isSelf) {conditionKey += '_self'}
				return conditionKey;
			},
			instsGet(forSubj) {
				let checkKey = forSubj ? 'subject_instrument_id' : 'object_instrument_id'
				let filter = this.instsToShow(forSubj);

				let possibles = this.possibles[this.value.contact_type]
				let toShow = [];
				let shown = {};
				for (var i = 0; i < possibles.length; i++) {
					let pos = possibles[i];
					let instID = pos[checkKey];
					if (shown[instID] || (forSubj && pos.object_instrument_id != this.value.object_instrument_id)) {
						continue;
					}

					let inst = this.instruments[instID];
					if (filter(inst)) {
						toShow.push(inst)
						shown[instID] = true;
					}

				}
				return toShow;
			},
			instsToShow(forSubj) {
				let conditionKey = this.getConditionKey(forSubj);

				// let contactKey = conditionKey;
				let checkUser = forSubj ? this._value.subject : this._value.object;
				let vm = this;
				return (inst) => {
					if (inst.conditions == null) {return true;}
					let conditions = inst.conditions.all || inst.conditions[conditionKey];
					if (conditions == undefined && vm.isSelf) {
						conditions = inst.conditions[conditionKey.replace("_self", "")]
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
				// let oldOrder = this.actorOrder

				// if (isInit) {
				// 	let origContact = this.contacts[this.value.contact_type]
				// 	// this.subj = origContact.subject || oldOrder[0]
				// 	// this.obj = origContact.object || oldOrder[1]
				// }

				// let newInd = this.subj == this.obj || this.subj == "self" ? 0 : 1;
				// if (newInd != this.orderInd) {
				// 	this.orderInd = newInd;

				// 	if (!isInit) {
				// 		let oldSubjInst = this._value[oldOrder[0] + "_instrument_id"]
				// 		let oldObjInst = this._value[oldOrder[1] + "_instrument_id"]

				// 		this._value[this.actorOrder[0] + "_instrument_id"] = oldSubjInst;
				// 		this._value[this.actorOrder[1] + "_instrument_id"] = oldObjInst;

				// 		this.onInput()
				// 	}
				// }

				this.updateContactType();
				if (isInit) {
					this.updateBarriers(this.value.barriers, true);
				}
			},
			updateContactType() {
				// let res = this._value.contact_type.replace(/(_self|_partner|_by)/g, "");
				// let didMatch = false;
				// for (let i = 0; i < this.possibleContacts.length; i++) {
				// 	let con = this.possibleContacts[i];
				// 	if (con.key.match(res)) {
				// 		this._value.contact_type = con.key;
				// 		didMatch = true;
				// 		break;
				// 	}
				// }

				// if (!didMatch) {
				// 	this._value.contact_type = this.possibleContacts[0].key;
				// }
				this.onInput();
				this.resetInsts()
				return;
			},
			updateBarriers(newBarriers, isInit) {
				let hadBarriers = this.value.barriers.indexOf("fresh") >=0
				let hasBarriers = newBarriers.indexOf("fresh") >= 0
				if (isInit || hadBarriers != hasBarriers) {
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
