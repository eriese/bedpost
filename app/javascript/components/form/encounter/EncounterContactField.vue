<template>
<div class="contact-field-container" :class="{blurred: !focused}">
	<input type="hidden" :value="value._id" :name="baseName + '[_id]'" v-if="!value.newRecord">
	<input type="hidden" :value="value.position" :name="baseName + '[position]'">
	<input type="hidden" :value="value.possible_contact_id" :name="baseName + '[possible_contact_id]'">
	<div class="contact-field">
		<div class="field-section narrow" role="radiogroup">
			<hidden-radio v-for="i in [{labelKey: 'I', inputValue: 'user'}, {label: partnerPronoun.subject, inputValue: 'partner'}]"
				:key="'subj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.subject"
				model="subject"
				@change="changeActorOrder">
			</hidden-radio>
		</div>
		<div class="field-section narrow" role="radiogroup">
			<hidden-radio v-for="c in contacts"
				:key="c.key" v-bind="{
					labelKey: 'contact.contact_type.' + c.t_key,
					inputValue: c.key,
					model: 'null',
					baseName}"
				v-model="contact_type"
				@change="resetInsts">
			</hidden-radio>
		</div>
		<div class="field-section narrow" role="radiogroup">
			<hidden-radio v-for="i in [{label: partnerPronoun.possessive, inputValue: 'partner'}, {labelKey: 'my', inputValue: 'user'}]"
				:key="'obj' + i.inputValue"
				v-bind="i"
				:base-name="baseName"
				v-model="_value.object"
				model="object"
				@change="changeActorOrder">
			</hidden-radio>
		</div>
		<div class="field-section" role="radiogroup">
			<hidden-radio v-for="oi in objectInsts"
				:key="oi._id"
				v-bind="{
					label: oi[value.object + '_name'],
					inputValue: oi._id,
					model: null,
					baseName
				}"
				v-model="object_instrument_id"
				@change="resetInsts(true)">
			</hidden-radio>
		</div>
		<div class="field-section narrow" role="radiogroup">
			<p v-html="subjPossessive"></p>
		</div>
		<div class="field-section" role="radiogroup">
			<hidden-radio v-for="si in subjectInsts" v-show="subjectInsts.length > 1"
				:key="si._id"
				v-bind="{
					label: si[value.subject + '_name'],
					inputValue: si._id,
					model: null,
					baseName
				}"
				v-model="subject_instrument_id"
				@change="setContact">
			</hidden-radio>
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
					objectName,
					subjectName,
					baseName,
					encounterData: {has_barrier: tracked.has_barrier, index: watchKey, instruments, object_instrument_id, subject_instrument_id}
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

	export default {
		data: function() {
			return Object.assign({}, gon.encounter_data, {
				orderInd: 0,
				objectInsts: [],
				subjectInsts: [],
				focused: true,
				onKeyChange: false,
				contact_type: "touched",
				subject_instrument_id: null,
				object_instrument_id: null,
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
			baseID: function() {
				return this.baseName.replace(/[\[\]\.]/g, "_")
			},
			cType: function() {
				return this.contacts[this.contact_type]
			},
			isSelf: function() {
				return this._value.subject == this._value.object;
			},
			objectName: function() {
				let p_inst_id = this.object_instrument_id
				return p_inst_id ? this.instruments[p_inst_id][this.value.object + '_name'] : ""
			},
			subjectName: function() {
				let p_inst_id = this.subject_instrument_id
				return p_inst_id ? this.instruments[p_inst_id][this.value.subject + '_name'] : ""
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
				let lst = e === true ? ['subject'] : ['object', 'subject']
				for (var s = 0; s < lst.length; s++) {
					let actorKey = lst[s];
					let instId = actorKey + '_instrument_id'
					let lstId = actorKey + "Insts";
					let newList = this[lstId + "Get"]();
					if (newList.length == 1) {
						this[instId] = newList[0]._id
					}
					else if (!newList.find((i) => i._id == this[instId])) {
						this[instId] = null;
					}
					this[lstId] = newList
				}
				this.setContact();
			},
			setContact() {
				if (this.contact_type && this.object_instrument_id && this.subject_instrument_id) {
					let contact = this.possibles[this.contact_type].find((i) => i.subject_instrument_id == this.subject_instrument_id && i.object_instrument_id == this.object_instrument_id);
					this._value.possible_contact_id = contact && contact._id;
				} else {
					this._value.possible_contact_id = null;
				}
				this.onInput();
			},
			objectInstsGet() {
				return this.instsGet(false);
			},
			subjectInstsGet() {
				if (!this.object_instrument_id) {
					return [];
				}

				return this.instsGet(true);
			},
			getConditionKey(forSubj) {
				let conditionKey = this.cType[forSubj ? 'inst_key' : 'inverse_inst']
				if (this.isSelf) {conditionKey += '_self'}
				return conditionKey;
			},
			instsGet(forSubj) {
				let checkKey = forSubj ? 'subject_instrument_id' : 'object_instrument_id'
				let filter = this.instsToShow(forSubj);

				let possibles = this.possibles[this.contact_type]
				let toShow = [];
				let shown = {};
				for (var i = 0; i < possibles.length; i++) {
					let pos = possibles[i];
					let instID = pos[checkKey];
					if (shown[instID] || (forSubj && pos.object_instrument_id != this.object_instrument_id)) {
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
				this.updateContactType();
				if (isInit) {
					this.updateBarriers(this.value.barriers, true);
				}
			},
			updateContactType() {
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
			if (this.value.possible_contact_id) {
				for (let p in this.possibles) {
					let found = this.possibles[p].find((i) => i._id == this.value.possible_contact_id);

					if (found) {
						this.contact_type = found.contact_type
						this.subject_instrument_id = found.subject_instrument_id
						this.object_instrument_id = found.object_instrument_id
						break;
					}
				}
			}
			this.changeActorOrder(null, true);
		}
	}
</script>
