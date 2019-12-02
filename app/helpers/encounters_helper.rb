module EncountersHelper

	def encounters_as_attributes
		attrs = if @partners.present?
			@partners.each_with_index.map do |partner, i|
				partner_name = partner.display(@partner_names[i])
				partner_class = "partnership-#{i}"
				partner.encounters.map { |enc| encounter_as_calendar_attr(enc, partner_class, partner_name) }
			end.flatten
		else
			@encounters.map {|enc| encounter_as_calendar_attr(enc)}
		end
		attrs.to_json
	end

	def encounter_as_calendar_attr(encounter, dot_class=false, partner_name=nil)
		{
			dates: encounter.took_place.to_json,
			highlight: dot_class == false,
			dot: dot_class,
			popover: {
				label: partner_name.present? ? "#{partner_name}: #{encounter.notes}" : encounter.notes,
				visibility: 'focus'
			}
		}
	end

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
			barrier_args = keys.merge(scope: 'contact.barrier')
			keys[:barriers] = contact.barriers.map { |b| t(b, barrier_args) }.join(t("and_delimeter"))
		end

		t_key += "_html"

		content_tag(:li, {class: "contact-show"}) do
			content_tag(:"drop-down") do
				content_tag(:span, t(t_key, keys), {slot: "title"}) +
					content_tag(:template, "v-slot:button": 'sc') do
						button_text = "{{sc.isOpen ? #{t('.display_risks_drop_down_html')}}}"
						content_tag(:button, button_text, type: 'button', class: 'not-button')
					end +
					display_risks(contact)
			end
		end
	end

	def display_risks(obj)
		is_encounter = obj.is_a? Encounter
		content_tag(:ul, class: 'risks-show') do
			grouped = group_risks_by_diagnosis(obj)
			risk_items = risk_inner_html(grouped, is_encounter)
			safe_join(risk_items)
		end
	end

	# write the html to display the recommended testing schedule based on the risks in this encounter
	def display_schedule(encounter, **options, &block)
		# was this schedule created with force = true?
		was_forced = false

		# sort the schedule dates, then loop
		sorted_keys = encounter.schedule.keys.sort do |a,b|
			if a.is_a?(Symbol)
				1
			elsif b.is_a? Symbol
				-1
			else
				a <=> b
			end
		end
		sched = sorted_keys.each_with_object([]) do |dt, ary|
			#add a list item to the array
			ary << content_tag(:li, {class: 'schedule-el'}) do
				# if the date is :routing
				if dt == :routine
					clss = 'schedule-routine'
					# give advice about getting routine testing
					date_txt = t('encounters.show.advice.routine')
					# add the given force button
					date_txt = capture(&block).prepend(date_txt) if block_given?
				else
					# otherwise, format the date
					date_txt = raw(l(dt, format: :best_test_html))
					clss = 'schedule-date'
				end

				# make a diagnosis string by mapping all the diagnoses to be tested for on the date
				diag_string = encounter.schedule[dt].map do |i|
					# translate the diagnosis name
					named = t(i, scope: 'diagnosis.name_casual')
					# if this would have been marked routine but isn't
					if dt != :routine && encounter.risks[i] <= Diagnosis::TransmissionRisk::ROUTINE_TEST_RISK
						# add an asterisk and mark that this is a forced schedule
						named += '*'
						was_forced = true
					end
					#return the string
					named
					#join them with the join delimeter
				end.join(t('join_delimeter'))

				# make the html with the resulting strings
				content_tag(:span, date_txt, {class: clss}) +
				content_tag(:span, diag_string, {class: 'schedule-diagnoses'})
			end
		end

		div = content_tag(:div, options) do
			inner = if was_forced || sorted_keys[0] != :routine
				content_tag(:p, t('encounters.show.advice.desc'))
			else
				ActiveSupport::SafeBuffer.new
			end

			inner += content_tag(:ul, safe_join(sched), class: 'schedule-show')
			if was_forced
				inner += content_tag(:div, t('encounters.show.advice.key_html'), {class: 'schedule-key'})
			end
			inner
		end
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
		person == :user ? current_user_profile : @partner
	end

	def display_risk(risk_level, risk_list)
		trans = t(
			'.risk_line_html',
			diagnosis: risk_list.join(t('join_delimeter')),
			level: t('diagnosis.transmission_risk.risk_level', count: risk_level)
		)
		content_tag(:li, trans, class: "risk-#{risk_level}")
	end

	def risk_inner_html(risk_groups, is_encounter)
		if risk_groups.empty?
			[content_tag(:li, class: 'risk-0') do
				content_tag(:span) do
					t('.risks.no_risks' + (is_encounter ? '' : '_contact'))
				end
			end]
		else
			risk_groups.each_with_object([]) { |(r, lst), a| a << display_risk(r, lst) }
		end
	end

	def group_risks_by_diagnosis(obj)
		obj.risks.each_with_object({}) do |(k, v), o|
			next if v == Diagnosis::TransmissionRisk::NO_RISK

			o[v] ||= []
			o[v] << t(k, scope: 'diagnosis.name_casual')
		end
	end
end
