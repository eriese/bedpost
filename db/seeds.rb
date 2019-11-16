############################
# Pronouns
############################
[
	{subject: "ze", object: "hir", possessive: "hir" , obj_possessive: "hirs", reflexive: "hirself"},
	{subject: "she", object: "her", possessive: "her", obj_possessive: "hers", reflexive: "herself"},
	{subject: "he", object: "him", possessive: "his", obj_possessive: "his", reflexive: "himself"},
	{subject: "they", object: "them", possessive: "their", obj_possessive: "theirs", reflexive: "themself"}
].each {|pr| Pronoun.create(pr)}

# seed a dev user who is already confirmed
if Rails.env.development?
	user = UserProfile.create(
		email: "devuser@bedpost.me",
		password: "password",
		password_confirmation: "password",
		confirmed_at: Time.now,
		name: "Dev User",
		anus_name: "anus",
		external_name: "external genitals",
		can_penetrate: true,
		pronoun: Pronoun.last
	)
end

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

############################
# Possible Contacts
############################
[{
	el: hand,
	contacts: {
		touched: [[external_genitals, true], [anus, true], [mouth, true], [hand, true], [toy, true], [tongue, true]],
		penetrated: [[internal_genitals, true],[anus, true],[mouth, true],[toy, true]],
		fisted: [[internal_genitals, true],[anus, true],[mouth, true]]
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

############################
# Diagnoses
############################
[
	{name: :chlamydia, gestation_min: 1, gestation_max: 4, in_fluids: true, local: true, category: [:curable, :bacterial, :common, :must_treat]},
	{name: :gonorrhea, gestation_min: 1, gestation_max: 3, in_fluids: true, local: true, category: [:curable, :bacterial, :common, :must_treat]},
	{name: :syphillis, gestation_min: 1, gestation_max: 12, in_fluids: true, local: true, category: [:curable, :bacterial, :common, :must_treat]},
	{name: :hiv, gestation_min: 4, gestation_max: 12, in_fluids: true, local: false, category: [:treatable, :viral, :must_treat]},
	{name: :hep_c, gestation_min: 6, gestation_max: 12, in_fluids: true, local: false, category: [:hep, :must_treat]},
	{name: :hep_b, gestation_min: 6, gestation_max: 12, in_fluids: true, local: false, category: [:hep, :viral, :must_treat]},
	{name: :hep_a, gestation_min: 2, gestation_max: 7, in_fluids: true, local: false, category: [:hep, :must_treat]},
	{name: :hsv, gestation_min: 3, gestation_max: 12, in_fluids: false, local: true, category: [:skin, :viral, :common, :not_standard, :managed]},
	{name: :hpv, gestation_min: 8, gestation_max: 80, in_fluids: false, local: true, category: [:skin, :viral, :self_clearing]},
	{name: :trich, gestation_min: 1, gestation_max: 4, in_fluids: true, local: true, category: [:parasitic, :common, :curable]},
	{name: :cmv, gestation_min: 3, gestation_max: 12, in_fluids: true, category: [:viral, :not_standard]},
	{name: :molluscum, gestation_min: 2, gestation_max: 24, in_fluids: false, local: true, category: [:not_standard, :skin, :self_clearing]},
	{name: :bv, gestation_min: 0, gestation_max: 1, in_fluids: true, local: true, only_vaginal: true, category: [:curable, :bacterial, :not_standard]},
	{name: :pubic_lice, gestation_min: 0, gestation_max: 1, in_fluids: false, local: true, category: [:skin, :curable]},
	{name: :scabies, gestation_min: 1, gestation_max: 2, in_fluids: false, local: true, category: [:skin, :parasitic, :curable]}
].each {|d| Diagnosis.new(d).upsert}

###########################
# Risks
###########################
NO_RISK = Diagnosis::TransmissionRisk::NO_RISK
NEGLIGIBLE = Diagnosis::TransmissionRisk::NEGLIGIBLE
LOW = Diagnosis::TransmissionRisk::LOW
MODERATE = Diagnosis::TransmissionRisk::MODERATE
HIGH = Diagnosis::TransmissionRisk::HIGH


PossibleContact.find_by(contact_type: :touched, subject_instrument_id: :hand, object_instrument_id: :external_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: NEGLIGIBLE}) } +
[Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: NO_RISK, risk_to_object: LOW, risk_to_self: LOW})]
PossibleContact.find_by(contact_type: :penetrated, subject_instrument_id: :hand, object_instrument_id: :internal_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map {|t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: LOW})} + [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: NO_RISK, risk_to_object: LOW, risk_to_self: LOW})]
PossibleContact.find_by(contact_type: :fisted, subject_instrument_id: :hand, object_instrument_id: :internal_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: LOW, risk_to_object: LOW}) } + [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: LOW, risk_to_object: LOW, risk_to_self: LOW})]

PossibleContact.find_by(contact_type: :touched, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: NEGLIGIBLE}) }
PossibleContact.find_by(contact_type: :penetrated, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map {|t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: LOW})}
PossibleContact.find_by(contact_type: :fisted, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: LOW, risk_to_object: LOW}) } + [Diagnosis::TransmissionRisk.new({diagnosis_id: :hep_c, risk_to_subject: HIGH, risk_to_object: HIGH})]
