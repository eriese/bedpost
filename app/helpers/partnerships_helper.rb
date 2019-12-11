module PartnershipsHelper
	def level_field_why_how(form_obj, attribute)
		content_tag(:aside, class: "additional", slot: "additional") do
			attr_explainer(form_obj, attribute, :why, :how)
		end
	end

	# display all the partners with their most recent encounters
	def display_partners
		# get an aggregate query of necessary info for the partnerships and their most recent encounter
		p_sorted = current_user_profile.partners_with_most_recent
		agg = p_sorted.map do |ship|
			# make a list item
			content_tag(:li, {class: "partnership-link"}) do
				# link to that partnership's show page
				link_to(partnership_path(ship["_id"]), class: 'as-button') do
					display_partner(ship)
				end
			end
		end
		# join and nest
		content_tag(:ul, safe_join(agg), {class: "partnership-links"})
	end

	# display a partner and their most recent encounter
	def display_partner(ship)
		ship_name = Partnership.make_display(ship["partner_name"], ship["nickname"])
		content = content_tag(:span, ship_name, {class: "partner-name"})

		#add the most recent if there is one
		most_recent = ship["most_recent"]
		content << content_tag(:span, t(".latest_html", {class: "last-encounter", took_place: l(most_recent, format: :most_recent)})) if most_recent

		content
	end

	private
	def attr_explainer(form_obj, attribute, exp_type, clear_type)
		toggle_key = form_obj.options[:wizard] ? exp_type : "#{exp_type}_#{attribute}"
		clear_key = form_obj.options[:wizard] ? clear_type : "#{clear_type}_#{attribute}"
		content_tag(:p) do
			form_obj.toggle_tag(toggle_key, symbols: t("helpers.toggles.partnership.#{exp_type}"), js_backup: true, :":expandable" => true, clear: "toggles.#{clear_key}")
		end +
		content_tag(:p, t("partnerships.new.#{exp_type}.#{attribute}"), :"v-show" => "vf.toggles.#{toggle_key}", class: "explanation")
	end
end
