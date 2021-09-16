# add inherited fields to translation defaults so that super classes get searched for attribute names, etc
ActionView::Helpers::Tags::Translator.class_eval do
	private def i18n_default
		if model
			defs = model.class.lookup_ancestors.map { |c| "#{c.model_name.i18n_key}.#{method_and_value}".to_sym }
			defs << ''
		else
			''
		end
	end
end
