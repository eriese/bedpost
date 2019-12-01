/** A functional component that displays an encounter list item*/
export default {
	name: 'encounter-list-item',
	functional: true,
	props: {
		encounter: Object,
		key: String
	},
	render: function(createElement, {props, data, parent}) {
		let encounter = props.encounter
		let encData = encounter.customData
		// translate for the inner html
		let innerHTML = parent.$_t('encounters.index.list_item_html', {
			date: parent.$_l('date.formats.short', encounter.dates),
			partner_name: encData.partnerName,
			href: encData.href,
			notes: encData.notes});

		// make a list item with two spans
		return createElement('li', {staticClass: 'encounter-list-item'}, [
			createElement('span', {
				staticClass: 'partner-indicator',
				class: encData.partnerClass
			}),
			createElement('span', {
				domProps: { innerHTML }
			})
		])
	}
}
