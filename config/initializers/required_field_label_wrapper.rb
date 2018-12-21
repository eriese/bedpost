# add an indicator that a field is required
ActionView::Helpers::Tags::Label.class_eval do
	private def render_component(builder)
		content = builder.translation
		content = I18n.t("helpers.required", {content: content}) if (@options[:required])
		content.html_safe
	end
end
