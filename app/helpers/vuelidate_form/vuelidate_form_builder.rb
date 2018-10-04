class VuelidateForm::VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	attr_reader :validations

	def field_wrapper(attribute, args = {}, &block)
		args[:"v-model"] = attribute
		args[:"@blur"] ||= "$v.#{attribute}.$touch()"
		@validations ||= []
		@validations << attribute unless args[:validate] == false
		@template.content_tag(:div, {class: 'field'}) do
			temp = args[:label] == false ? "" : label(attribute, args[:label])
			temp+= @template.content_tag("field-errors", "", {field: attribute, ":v" => "$v"})
			temp+= block.call
		end
	end

	def text_field(attribute, args = {})
		field_wrapper(attribute, args) do
			super
		end
	end

	def password_field(attribute, args = {})
		field_wrapper(attribute, args) do
			super
		end
	end

end
