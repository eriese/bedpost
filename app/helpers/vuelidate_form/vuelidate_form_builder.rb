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

  [:radio_button, :hidden_field].each do |selector|
  	class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
			def #{selector}(method, options = {})  # def text_field(method, options = {})
		    add_v_model(method, options)
		  	super
		  end                                    # end
    RUBY_EVAL
  end

  def check_box(attribute, args={}, checked_value = "1", unchecked_value = "0")
  	add_v_model(attribute, args)
  	super(attribute, args, checked_value, unchecked_value)
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
  			@template.content_tag(:a, "{{passText}}", {"@click" => "toggle('password')", class: "no-line"})
  		end
  	end
  end

	def field_wrapper(attribute, args = {}, after_method, &block)
		add_v_model(attribute, args)

		field_args = {class: 'field'}
		if args[:show_if] || args[:"v-show"]
			field_args[:"v-show"] = args[:"v-show"] || full_v_name(args[:show_if])
			args.delete(:show_if)
			args.delete(:"v-show")
		end

		@template.content_tag(:div, field_args) do
			temp = block.call
			temp = label(attribute, args[:label]) + temp unless args[:label] == false
			temp += error_fields(attribute, args)
			temp += send(after_method) unless after_method.nil?
			temp
		end
	end

	def error_fields(attribute, args={})
		unless args[:validate] == false
		error_props = {field: attribute, ":v" => "$v", ":submission-error" => "submissionError"}
			error_props["model-name"] = @object_name unless @object_name.blank?
			@template.content_tag("field-errors", "",  error_props)
		end
	end

	def form_errors
		@template.content_tag("form-errors", "", {":submission-error" => "submissionError"})
	end

	private
	def full_v_name(attribute)
		"formData.#{@object_name}.#{attribute}"
	end
	def add_v_model(attribute, args={})
		full_name = full_v_name attribute
		args[:"v-model"] ||= full_name
		args[:ref] ||= attribute

		unless args[:validate] == false
			args[:"@blur"] ||= "touch($v.#{full_name})"
			@validations ||= []
			@validations << attribute
		end
	end
end
