module PartnershipsHelper
	def level_field_why_how(form_obj, attribute)
		content_tag(:aside, class: "additional", slot: "additional") do
			attr_explainer(form_obj, attribute, :why, :how) +
			attr_explainer(form_obj, attribute, :how, :why)
		end
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
