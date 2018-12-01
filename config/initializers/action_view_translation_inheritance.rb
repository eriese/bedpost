# add inherited fields to translation defaults so that super classes get searched for attribute names, etc
ActionView::Helpers::Tags::Translator.class_eval do
	private def i18n_default
		if model
			clazz = model.class
			defs = []
			until clazz == Object
				key = clazz.model_name.i18n_key
				defs << "#{key}.#{method_and_value}".to_sym
				clazz = clazz.superclass
			end
			defs << ""
		else
			""
		end
	end
end
