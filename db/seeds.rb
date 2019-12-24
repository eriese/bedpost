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

# temporary terms of use
Terms.create(terms: "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Eligendi, inventore delectus, laborum excepturi repudiandae, ex quae eveniet, modi culpa sequi distinctio perspiciatis voluptate sint molestiae! Iure suscipit, vitae eaque ut. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Illo quibusdam eum et quis ipsum consectetur iusto eligendi labore ab quaerat in tempora fuga eaque debitis, delectus incidunt, minus alias amet. \n Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ex ducimus quis voluptatem sed pariatur optio dignissimos. Eum vero quibusdam ducimus cumque earum dicta accusantium a libero aut debitis, facere repellendus! \n Lorem ipsum dolor sit amet, consectetur adipisicing elit. Doloremque provident iusto suscipit sunt incidunt explicabo laudantium culpa dolore quo totam eligendi, ea unde tenetur quidem, illo dolor neque, aliquam commodi.", type: :tou)
Terms.create(terms: "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Doloribus eius omnis expedita, eveniet id ut molestiae deserunt, libero modi magni adipisci sed ea non ipsam repellendus voluptas quia nihil labore!", type: :privacy)

############################
# Contact Instruments
############################
hand = Contact::Instrument.new(name: :hand, has_fluids: false)
hand.upsert
external_genitals = Contact::Instrument.new(name: :external_genitals, user_override: :external_name, conditions: {
	can_be_penetrated_by: [:can_penetrate], can_penetrate: [:can_penetrate], can_be_sucked_by_self: [:can_penetrate]
})
external_genitals.upsert
internal_genitals = Contact::Instrument.new(name: :internal_genitals, user_override: :internal_name, conditions: {
	all: [:internal_name]
})
internal_genitals.upsert
anus = Contact::Instrument.new(name: :anus, user_override: :anus_name)
anus.upsert
mouth = Contact::Instrument.new(name: :mouth)
mouth.upsert
toy = Contact::Instrument.new(name: :toy, has_fluids: false)
toy.upsert
tongue = Contact::Instrument.new(name: :tongue, alias_of: mouth)
tonuge.upsert
fingers = Contact::Instrument.new(name: :fingers, has_fluids: false, alias_of: hand)
fingers.upsert

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

PossibleContact.where(subject_instrument_id: :hand, contact_type: :penetrated).update_all(subject_instrument_id: :fingers)
PossibleContact.where(object_instrument_id: :hand, contact_type: :sucked).update_all(object_instrument_id: :fingers)

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
PossibleContact.find_by(contact_type: :penetrated, subject_instrument_id: :fingers, object_instrument_id: :internal_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map {|t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: LOW})} + [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: NO_RISK, risk_to_object: LOW, risk_to_self: LOW})]
PossibleContact.find_by(contact_type: :fisted, subject_instrument_id: :hand, object_instrument_id: :internal_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: LOW, risk_to_object: LOW}) } + [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: LOW, risk_to_object: LOW, risk_to_self: LOW})]

PossibleContact.find_by(contact_type: :touched, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: NEGLIGIBLE}) }
PossibleContact.find_by(contact_type: :penetrated, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map {|t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: LOW})}
PossibleContact.find_by(contact_type: :fisted, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: LOW, risk_to_object: LOW}) } + [Diagnosis::TransmissionRisk.new({diagnosis_id: :hep_c, risk_to_subject: HIGH, risk_to_object: HIGH})]

#############################
# TOURS
#############################
def insert_tours(tour_configs)
	orig_locale = I18n.locale
	tour_configs.each do |page_name, tour_nodes|
		tour = Tour.find_or_create_by(page_name: page_name)
		tour.tour_nodes = tour_nodes.map do |node|
			tour_node = TourNode.new(target: node[:target], position: node[:position])
			node[:content].each do |locale, txt|
				I18n.locale = locale
				tour_node.content = txt
			end
			tour_node
		end

		tour.save
	end
	I18n.locale = orig_locale
end

tour_configs = {
	'-profile' => [{
		target: '.description',
		position: 0,
		content: {
			en: 'We created your account! Before we get into the fun stuff, tell us about yourself so we can talk about you in ways that feel good and fun.'
		}
	}],
	'-partners-new' => [{
		target: '.stepper__step:nth-child(2) .field .slide-bar-desc',
		await_in_view: true,
		position: 0,
		content: {
			en: "Here's why we want to know: we use this data to calculate risk mitigation, if you're not sure, you should round down because a partnership can never increase your risk, it can only decrease it."
		}
	}]
}

insert_tours(tour_configs)
