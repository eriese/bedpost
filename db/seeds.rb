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
HAND = Contact::Instrument.create(name: "hand")
EXTERNAL_GENITALS = Contact::Instrument.create(name: "external_genitals", user_override: :external_name, conditions: {
	can_be_penetrated_by: [:can_penetrate], can_penetrate: [:can_penetrate]
})
INTERNAL_GENITALS = Contact::Instrument.create(name: "internal_genitals", user_override: :internal_name, conditions: {
	all: [:internal_name]
})
ANUS = Contact::Instrument.create(name: "anus", user_override: :anus_name)
MOUTH = Contact::Instrument.create(name: "mouth")
TOYS = Contact::Instrument.create(name: "toys")

HAND.can_touch.concat [EXTERNAL_GENITALS, ANUS, MOUTH, HAND, TOYS]
HAND.can_penetrate.concat [INTERNAL_GENITALS, ANUS, MOUTH]
Hand.can_touch_self.concat [EXTERNAL_GENITALS, ANUS, MOUTH, HAND, TOYS]
HAND.can_penetrate_self.concat [INTERNAL_GENITALS, ANUS, MOUTH, TOYS]

EXTERNAL_GENITALS.can_touch.concat [ANUS, MOUTH, TOYS, EXTERNAL_GENITALS]
EXTERNAL_GENITALS.can_penetrate.concat [INTERNAL_GENITALS, ANUS, MOUTH, TOYS]
EXTERNAL_GENITALS.can_touch_self.concat [TOYS, MOUTH]
EXTERNAL_GENITALS.can_penetrate_self.concat [ANUS, MOUTH, TOYS]

MOUTH.can_touch.concat [ANUS, MOUTH, TOYS]
MOUTH.can_penetrate.concat [INTERNAL_GENITALS, ANUS, MOUTH, TOYS]
MOUTH.can_touch_self.concat [TOYS]

TOYS.can_touch.concat [ANUS, TOYS]
TOYS.can_penetrate.concat [EXTERNAL_GENITALS, INTERNAL_GENITALS, ANUS, MOUTH, TOYS]
TOYS.can_touch_self.concat [ANUS, TOYS]
TOYS.can_penetrate_self.concat [EXTERNAL_GENITALS, INTERNAL_GENITALS, ANUS, MOUTH, TOYS]
