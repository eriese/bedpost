if Rails.env.development? || Rails.env.test?

end

############################
# Pronouns
############################
PRONOUNS = [
	{subject: "ze", object: "hir", possessive: "hir" , obj_possessive: "hirs", reflexive: "hirself"},
	{subject: "she", object: "her", possessive: "her", obj_possessive: "hers", reflexive: "herself"},
	{subject: "he", object: "him", possessive: "his", obj_possessive: "his", reflexive: "himself"},
	{subject: "they", object: "them", possessive: "their", obj_possessive: "theirs", reflexive: "themself"}
]

PRONOUNS.each {|pr| Pronoun.create(pr)}

############################
# Contact Instruments
############################
hand = Contact::Instrument.create(name: :hand)
external_genitals = Contact::Instrument.create(name: :external_genitals, user_override: :external_name, conditions: {
	can_be_penetrated_by: [:can_penetrate], can_penetrate: [:can_penetrate], can_be_sucked_by_self: [:can_penetrate]
})
internal_genitals = Contact::Instrument.create(name: :internal_genitals, user_override: :internal_name, conditions: {
	all: [:internal_name]
})
anus = Contact::Instrument.create(name: :anus, user_override: :anus_name)
mouth = Contact::Instrument.create(name: :mouth)
toy = Contact::Instrument.create(name: :toy)
tongue = Contact::Instrument.create(name: :tongue)

[{
	el: hand,
	contacts: {
		touched: [[external_genitals, true], [anus, true], [mouth, true], [hand, true], [toy, true], [tongue, true]],
		penetrated: [[internal_genitals, true],[anus, true],[mouth, true],[toy, true]]
	}
},{
	el: external_genitals,
	contacts: {
		touched: [[anus,false],[mouth,true],[toy,true],[external_genitals,false],[tongue,true]],
		penetrated: [[internal_genitals,false], [anus,true], [mouth,true], [toy,true]]
	}
},{
	el: mouth,
	contacts: {
		touched: [[anus,false], [mouth,false], [toy,true], [tongue,false]],
		sucked: [[hand,true], [external_genitals,true], [anus,false], [mouth,false], [toy,true], [tongue,false]]
	}
},{
	el: toy,
	contacts: {
		touched: [[anus,true], [toy,true], [tongue,true]],
		penetrated: [[external_genitals,true], [internal_genitals,true], [anus,true], [mouth,true], [toy,true]]
	}
},{
	el: tongue,
	contacts: {
		touched: [[tongue,false]],
		penetrated: [[external_genitals,false], [internal_genitals,false], [anus,false], [mouth,false], [toy,false]]
	}
}].each do |inst|
	inst[:contacts].each do |c, i_lst|
		i_lst.each do |i|
			PossibleContact.new(contact_type: c, subject_instrument: inst[:el], object_instrument: i[0], self_possible: i[1]).upsert
			PossibleContact.new(contact_type: c, subject_instrument: i[0], object_instrument: inst[:el], self_possible: i[1]).upsert if c == :touched
		end
	end
end
