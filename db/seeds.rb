############################
# Pronouns
############################
[
	{ subject: 'ze', object: 'hir', possessive: 'hir', obj_possessive: 'hirs', reflexive: 'hirself' },
	{ subject: 'she', object: 'her', possessive: 'her', obj_possessive: 'hers', reflexive: 'herself' },
	{ subject: 'he', object: 'him', possessive: 'his', obj_possessive: 'his', reflexive: 'himself' },
	{ subject: 'they', object: 'them', possessive: 'their', obj_possessive: 'theirs', reflexive: 'themself' }
].each { |pr| Pronoun.find_or_create_by(pr) }

# seed a dev user who is already confirmed
if Rails.env.development?
	user = UserProfile.find_or_create_by(
		email: 'devuser@bedpost.me',
		password: 'password',
		password_confirmation: 'password',
		name: 'Dev User',
		anus_name: 'anus',
		external_name: 'external genitals',
		can_penetrate: true,
		pronoun: Pronoun.last
	)
end

############################
# Contact Instruments
############################
hand = Contact::Instrument.new(
	name: :hand,
	has_fluids: false,
	can_clean: true
)
hand.upsert
fingers = Contact::Instrument.new(
	name: :fingers,
	has_fluids: false,
	can_clean: false,
	alias_of: hand
)
fingers.upsert

external_genitals = Contact::Instrument.new(
	name: :external_genitals,
	user_override: :external_name,
	conditions: {
		can_be_penetrated_by: [:can_penetrate],
		can_penetrate: [:can_penetrate],
		can_be_sucked_by_self: [:can_penetrate],
		can_be_kissed_by_self: [:can_penetrate],
		can_be_licked_by_self: [:can_penetrate]
	}
)
external_genitals.upsert

internal_genitals = Contact::Instrument.new(
	name: :internal_genitals,
	user_override: :internal_name,
	conditions: {
		all: [:internal_name]
	}
)
internal_genitals.upsert

anus = Contact::Instrument.new(name: :anus, user_override: :anus_name)
anus.upsert
mouth = Contact::Instrument.new(name: :mouth)
mouth.upsert
tongue = Contact::Instrument.new(name: :tongue, alias_of: mouth)
tongue.upsert
toy = Contact::Instrument.new(name: :toy, has_fluids: false, can_clean: true)
toy.upsert

############################
# Possible Contacts
############################
[{
	el: hand,
	contacts: {
		touched: [[external_genitals, true], [anus, true], [mouth, true], [hand, true], [toy, true], [tongue, true]],
		penetrated: [[internal_genitals, true], [anus, true], [mouth, true], [toy, true]],
		fisted: [[internal_genitals, true], [anus, true], [mouth, true]]
	}
}, {
	el: external_genitals,
	contacts: {
		touched: [[anus, false], [mouth, true], [toy, true], [external_genitals, false], [tongue, true]],
		penetrated: [[internal_genitals, false], [anus, true], [mouth, true], [toy, true]]
	}
}, {
	el: mouth,
	contacts: {
		touched: [[anus, false], [mouth, false], [toy, true], [tongue, false]],
		sucked: [[hand, true], [external_genitals, true], [anus, false], [mouth, false], [toy, true], [tongue, false]]
	}
}, {
	el: toy,
	contacts: {
		touched: [[anus, true], [toy, true], [tongue, true]],
		penetrated: [[external_genitals, true], [internal_genitals, true], [anus, true], [mouth, true], [toy, true]]
	}
}, {
	el: tongue,
	contacts: {
		touched: [[tongue, false]],
		penetrated: [[external_genitals, false], [internal_genitals, false], [anus, false], [mouth, false], [toy, false]],
		licked: [[anus, false]]
	}
}].each do |inst|
	inst[:contacts].each do |c, i_lst|
		i_lst.each do |i|
			PossibleContact.find_or_create_by(contact_type: c, subject_instrument: inst[:el], object_instrument: i[0],
																																					self_possible: i[1])
			PossibleContact.find_or_create_by(contact_type: c, subject_instrument: i[0], object_instrument: inst[:el],
																																					self_possible: i[1]) if c == :touched
		end
	end
end

PossibleContact.where(subject_instrument_id: :hand,
																						contact_type: :penetrated).update_all(subject_instrument_id: :fingers)
PossibleContact.where(object_instrument_id: :hand, contact_type: :sucked).update_all(object_instrument_id: :fingers)

PossibleContact.where(subject_instrument_id: :mouth, contact_type: :touched).update_all(contact_type: :kissed)
PossibleContact.where(subject_instrument_id: :tongue, contact_type: :touched).update_all(contact_type: :licked)

############################
# Diagnoses
############################
[
	{ name: :chlamydia, gestation_min: 1, gestation_max: 4, in_fluids: true, local: true,
			category: [:curable, :bacterial, :common, :must_treat] },
	{ name: :gonorrhea, gestation_min: 1, gestation_max: 3, in_fluids: true, local: true,
			category: [:curable, :bacterial, :common, :must_treat] },
	{ name: :syphillis, gestation_min: 1, gestation_max: 12, in_fluids: true, local: true,
			category: [:curable, :bacterial, :common, :must_treat] },
	{ name: :hiv, gestation_min: 4, gestation_max: 12, in_fluids: true, local: false,
			category: [:treatable, :viral, :must_treat] },
	{ name: :hep_c, gestation_min: 6, gestation_max: 12, in_fluids: true, local: false, category: [:hep, :must_treat] },
	{ name: :hsv, gestation_min: 3, gestation_max: 12, in_fluids: false, local: true,
			category: [:skin, :viral, :common, :not_standard, :managed] },
	{ name: :hpv, gestation_min: 8, gestation_max: 80, in_fluids: false, local: true,
			category: [:skin, :viral, :self_clearing] },
	{ name: :bv, gestation_min: 0, gestation_max: 1, in_fluids: true, local: true, only_vaginal: true,
			category: [:curable, :bacterial, :not_standard] },

	# {name: :trich, gestation_min: 1, gestation_max: 4, in_fluids: true, local: true, category: [:parasitic, :common, :curable]},
	# {name: :cmv, gestation_min: 3, gestation_max: 12, in_fluids: true, category: [:viral, :not_standard]},
	# {name: :molluscum, gestation_min: 2, gestation_max: 24, in_fluids: false, local: true, category: [:not_standard, :skin, :self_clearing]},
	# {name: :pubic_lice, gestation_min: 0, gestation_max: 1, in_fluids: false, local: true, category: [:skin, :curable]},
	# {name: :scabies, gestation_min: 1, gestation_max: 2, in_fluids: false, local: true, category: [:skin, :parasitic, :curable]}
].each { |d| Diagnosis.find_or_create_by(d) }

###########################
# Risks
###########################
NO_RISK = Diagnosis::TransmissionRisk::NO_RISK
NEGLIGIBLE = Diagnosis::TransmissionRisk::NEGLIGIBLE
LOW = Diagnosis::TransmissionRisk::LOW
MODERATE = Diagnosis::TransmissionRisk::MODERATE
HIGH = Diagnosis::TransmissionRisk::HIGH

# PossibleContact.find_by(contact_type: :touched, subject_instrument_id: :hand, object_instrument_id: :external_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: NEGLIGIBLE}) } +
# [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: NO_RISK, risk_to_object: LOW, risk_to_self: LOW})]
# PossibleContact.find_by(contact_type: :penetrated, subject_instrument_id: :fingers, object_instrument_id: :internal_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map {|t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: LOW})} + [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: NO_RISK, risk_to_object: LOW, risk_to_self: LOW})]
# PossibleContact.find_by(contact_type: :fisted, subject_instrument_id: :hand, object_instrument_id: :internal_genitals).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: LOW, risk_to_object: LOW}) } + [Diagnosis::TransmissionRisk.new({diagnosis_id: :bv, risk_to_subject: LOW, risk_to_object: LOW, risk_to_self: LOW})]

# PossibleContact.find_by(contact_type: :touched, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: NEGLIGIBLE}) }
# PossibleContact.find_by(contact_type: :penetrated, subject_instrument_id: :fingers, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map {|t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: NEGLIGIBLE, risk_to_object: LOW})}
# PossibleContact.find_by(contact_type: :fisted, subject_instrument_id: :hand, object_instrument_id: :anus).transmission_risks = [:hpv, :chlamydia, :hsv, :syphillis].map { |t| Diagnosis::TransmissionRisk.new({diagnosis_id: t, risk_to_subject: LOW, risk_to_object: LOW}) } + [Diagnosis::TransmissionRisk.new({diagnosis_id: :hep_c, risk_to_subject: HIGH, risk_to_object: HIGH})]

#############################
# TOURS
#############################
def insert_tours(tour_configs)
	Tour.destroy_all
	orig_locale = I18n.locale
	tour_configs.each do |page_name, tour_nodes|
		fte_only = tour_nodes.shift if !!tour_nodes[0] == tour_nodes[0]
		tour = Tour.find_or_create_by(page_name: page_name, fte_only: fte_only || false)
		tour.tour_nodes = tour_nodes.map do |node|
			tour_node = TourNode.new(target: node[:target], position: node[:position], await_in_view: node[:await_in_view])
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
	'-profile' => [true, {
		target: '.description',
		position: 0,
		content: {
			en: 'We created your account! Before we get into the fun stuff, tell us about yourself so we can talk about you in ways that feel good and fun.'
		}
	}],
	'-partners-new-0' => [{
		target: '#partnership_uid',
		await_in_view: true,
		position: 0,
		content: {
			en: 'If your partner also uses BedPost, connecting with their userID is a handy shortcut to using the body language they like.'
		}
	}, {
		target: '#partnership_partner_attributes_name',
		await_in_view: true,
		position: 1,
		content: {
			en: "If you don't have their id, just give us their name and we'll walk you through putting the language in later."
		}
	}],
	'-partners-new-1' => [{
		target: '.stepper__step:nth-child(2) .field .slide-bar-desc',
		await_in_view: true,
		position: 2,
		content: {
			en: "Pick what sounds the most true, even if it's not exact. If you're not sure, it's best to round down."
		}
	}],
	'-partners--encounters-new' => [{
		target: '#encounter_notes',
		position: 0,
		content: {
			en: 'This section is just for you. You can leave it blank or write anything you want to remember about this encounter.'
		}
	}, {
		target: '.dynamic-field-list__item:first-of-type',
		position: 1,
		content: {
			en: "Fill this out like sexy madlibs. As you make your selections, you'll see the options change to allow you to tell us the whole story."
		}
	}, {
		target: '.cta--is-add-btn',
		position: 2,
		content: {
			en: 'When we say we want the details, we mean ALL the details. Add as many contacts as you can remember.'
		}
	}],
	'-partners--encounters-' => [{
		target: '#tippy-2 .tippy-tooltip',
		position: 0,
		await_in_view: true,
		content: {
			en: 'Here you can see how your sense of this encounter compares to ours. We like it as a way to gauge whether you tend to over or underestimate.'
		},
	}, {
		target: '#contact-review .dropdown-button',
		position: 1,
		content: {
			en: 'Look here to see what you got up to, and the transmission likelihood from each contact'
		}
	}, {
		target: '#risk-review .dropdown-button',
		position: 2,
		content: {
			en: 'Here you can check out what we calculated as the overall chances of STI transmission from this encounter'
		}
	}, {
		target: '#schedule-review',
		position: 3,
		content: {
			en: 'This is what we think is a good testing schedule based on what you told us. For stuff that\'s pretty unlikely we\'ll always recommend just making sure your doctor checks it on your next test. For higher likelihoods we\'ll tell you the soonest you can get a test with a reliable result.'
		}
	}]
}

insert_tours(tour_configs)
