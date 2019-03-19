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
	can_be_penetrated_by: [:can_penetrate], can_penetrate: [:can_penetrate]
})
internal_genitals = Contact::Instrument.create(name: :internal_genitals, user_override: :internal_name, conditions: {
	all: [:internal_name]
})
anus = Contact::Instrument.create(name: :anus, user_override: :anus_name)
mouth = Contact::Instrument.create(name: :mouth)
toy = Contact::Instrument.create(name: :toy)

hand.can_touch << external_genitals << anus << mouth << hand << toy
hand.can_penetrate << internal_genitals << anus << mouth
hand.can_touch_self << external_genitals << anus << mouth << hand << toy
hand.can_penetrate_self << internal_genitals << anus << mouth << toy

external_genitals.can_touch << anus << mouth << toy << external_genitals
external_genitals.can_penetrate << internal_genitals << anus << mouth << toy
external_genitals.can_touch_self << toy << mouth
external_genitals.can_penetrate_self << anus << mouth << toy

mouth.can_touch << anus << mouth << toy
mouth.can_penetrate << internal_genitals << anus << mouth << toy
mouth.can_touch_self << toy

toy.can_touch << anus << toy
toy.can_penetrate << external_genitals << internal_genitals << anus << mouth << toy
toy.can_touch_self << anus << toy
toy.can_penetrate_self << external_genitals << internal_genitals << anus << mouth << toy
