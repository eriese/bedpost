module EncountersHelper

	def display_contacts(encounter)
		@t_block ||= method(:t)
		@partner = encounter.partnership.partner
		content_tag(:ul, safe_join(encounter.contacts.map { |c| display_contact(c) }), {class: "contacts-show no-dots"})
	end

	def display_contact(contact)
		possible = get_possible(contact)
		obj_user = contact.object == :user
		subj_user = contact.subject == :user

		keys = {
			subject_pronoun: (subj_user ? t("you") : @partner.name).capitalize,
			contact_type: t(possible.contact_type.key, {scope: "contact.contact_type"}),
			object_possessive: obj_user ? t("your") : @partner.name_possessive,
			object_instrument: get_instrument(possible, contact, true),
			subject_possessive: subj_user ? t("your") : @partner.pronoun.possessive,
			subject_instrument: get_instrument(possible, contact, false),
		}

		t_key = ".contact"
		if contact.barriers.any?
			t_key += "_with_barriers"
			barrier_args = keys.slice(:object_instrument, :subject_instrument).merge({scope: "contact.barrier"})
			keys[:barriers] = contact.barriers.map { |b| t(b, barrier_args) }.join(t("and_delimeter"))
		end

		t_key += "_html"

		content_tag(:li, {class: "contact-show"}) do
			content_tag(:"drop-down") do
				content_tag(:span, t(t_key, keys), {slot: "title"}) +
				display_risks(contact)
			end
		end
	end

	def display_risks(obj)
		@diagnoses ||= Diagnosis.as_map
		grouped = obj.risks.each_with_object({}) do |(k,v), o|
			next if v == Diagnosis::TransmissionRisk::NO_RISK
			o[v] ||= []
			o[v] << t(k, scope: "diagnosis.name_casual")
		end
		risks = grouped.each_with_object([]) do |(r, lst), a|
			trans = t(".risk_line_html", {diagnosis: lst.join(t("join_delimeter")), level: t("diagnosis.transmission_risk.risk_level", {count: r})})
			a << content_tag(:li, trans, {class: "risk-#{r}"})
		end

		# button_key = obj.is_a?(Encounter) ? ".display_overall_risks_drop_down_html" : ".display_risks_drop_down_html"

		content_tag(:template, {:"v-slot:button" => "sc"}) do
			content_tag(:button, "{{sc.isOpen ? #{t(".display_risks_drop_down_html")}}}", {type: "button", class: "not-button"}) unless obj.is_a?(Encounter)
		end +
		content_tag(:ul, safe_join(risks), {class: "risks-show"})
	end

	private
	def get_possible(contact)
		@possibles ||= PossibleContact.as_map
		@possibles[contact.possible_contact_id]
	end

	def get_instrument(possible, contact, is_object)
		inst_id = is_object ? possible.object_instrument_id : possible.subject_instrument_id
		@instruments ||= Contact::Instrument.as_map
		person = get_contact_person(contact, is_object)
		@instruments[inst_id].get_user_name_for(person, &@t_block)
	end

	def get_contact_person(contact, is_object)
		person = is_object ? contact.object : contact.subject
		person == :user ? current_user : @partner
	end

end
