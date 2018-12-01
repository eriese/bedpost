class VuelidateForm::VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	attr_reader :validations

	(field_helpers - [:fields_for, :fields, :label, :check_box, :radio_button,  :hidden_field, :password_field]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})  # def text_field(method, options = {})
        field_wrapper(method, options) do
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
  	super
  end

  def select(attribute, choices = nil, options = {}, html_options=nil, &block)
		html_options ||= options[:html] || {}
		html_options[:label] = options.delete(:label) if html_options[:label].nil?
		html_options[:class] ||= options.delete(:class)
  	field_wrapper(attribute, html_options) do
  		super
  	end
  end


  def password_field(attribute, args={})
  	args[":type"] = "passType"
  	after_method = args[:show_toggle] ? :password_toggle : nil
  	field_wrapper(attribute, args, after_method) do
  		super
  	end
  end

  def password_toggle
  	@template.content_tag(:div, {class: "additional"}) do
  		@template.content_tag(:p) do
  			@template.content_tag(:a, "{{passText}}", {"@click" => "toggle('password')", class: "no-line"})
  		end
  	end
  end

  def field(attribute, options = {}, &block)
  	options[:class] = options.has_key?(:class) ? options[:class] + ' field' : 'field'
  	label_opt = options.delete(:label)
  	@template.content_tag(:div, options) do
  		@template.concat(label(attribute, label_opt)) unless label_opt == false
  		@template.concat(block.call)
		end
	end


	def field_wrapper(attribute, args = {}, after_method = nil, &block)
		add_v_model(attribute, args)

		field_args = {label: args[:label]}
		if args[:show_if] || args[:"v-show"]
			field_args[:"v-show"] = args[:"v-show"] || full_v_name(args[:show_if])
		end

		field(attribute, field_args) do
			@template.capture do
				@template.concat block.call
				@template.concat error_fields(attribute, args)
				@template.concat send(after_method) unless after_method.nil?
			end
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

	def objectify_options(options)
	  super.except(:label, :validate, :show_toggle, :"v-show", :show_if)
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
