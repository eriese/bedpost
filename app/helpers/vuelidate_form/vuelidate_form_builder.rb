class VuelidateForm::VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	attr_reader :validations

	(field_helpers - [:fields_for, :fields, :label, :check_box, :radio_button,  :hidden_field, :password_field]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})  # def text_field(method, options = {})
        field_wrapper(method, options, nil) do
        	super
        end
      end                                    # end
    RUBY_EVAL
  end

  def password_field(attribute, args={})
  	args[":type"] = "passType"
  	after_method = args[:show_toggle] ? :password_toggle : nil
  	field_wrapper(attribute, args, after_method) do
  		temp = super(attribute, args)
  	end
  end

  def password_toggle
  	@template.content_tag(:div, {class: "additional"}) do
  		@template.content_tag(:p) do
  			@template.content_tag(:a, "{{passText}}", {"@click" => "togglePassword", class: "no-line"})
  		end
  	end
  end

	def field_wrapper(attribute, args = {}, after_method, &block)
		add_v_model(attribute, args)

		@template.content_tag(:div, {class: 'field'}) do
			temp = block.call
			temp = label(attribute, args[:label]) + temp unless args[:label] == false
			temp += error_fields(attribute, args)
			temp += send(after_method) unless after_method.nil?
			temp
		end
	end

	def error_fields(attribute, args={})
		unless args[:validate] == false
		error_props = {field: attribute, ":v" => "$v"}
			error_props["model-name"] = @object_name unless @object.nil?
			@template.content_tag("field-errors", "",  error_props)
		end
	end

	private
	def add_v_model(attribute, args={})
		args[:"v-model"] = attribute
		args[:ref] ||= attribute

		unless args[:validate] == false
			args[:"@blur"] ||= "$v.#{attribute}.$touch()"
			@validations ||= []
			@validations << attribute
		end
	end
end
