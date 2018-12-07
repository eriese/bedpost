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
  	args[":type"] = "toggles['password']"
  	after_method = args[:show_toggle] ? :password_toggle : nil
  	field_wrapper(attribute, args, after_method) do
  		super
  	end
  end

  def password_toggle
  	@template.content_tag(:div, {class: "additional"}) do
  		@template.content_tag(:p) do
  			toggle_tag(:password, {class: "no-line", :":symbols" => "['hide_password', 'show_password']", :":translate" => true, :":vals" => "['text', 'password']"})
  		end
  	end
  end

  def field(attribute, options = {}, &block)
  	add_to_class(options, "field")
  	label_opt = options.delete :label
  	tooltip_opt = options.delete :tooltip
  	before_label = options.delete :before_label
  	@template.content_tag(:div, options) do
  		@template.concat(block.call) if before_label
			@template.concat field_label(attribute, label_opt) unless label_opt == false
  		@template.concat tooltip(attribute, tooltip_opt) if tooltip_opt
  		@template.concat(block.call) unless before_label
		end
	end

	def field_wrapper(attribute, args = {}, after_method = nil, &block)
		add_v_model(attribute, args)

		field_args = args.slice :label, :tooltip, :before_label
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
		@template.content_tag("form-errors", "", {:":submission-error" => "submissionError"})
	end

	def toggle(attribute, options={}, toggle_options={})
		field(attribute, options.merge({class: "inline", before_label: true})) do
			toggle_tag(attribute, toggle_options)
		end
	end

	def toggle_tag(attribute, toggle_options)
		clear_opt = toggle_options.delete :":clear"
		if clear_opt
			clear_attr = clear_opt == true ? attribute : clear_opt
			toggle_options[:":clear"] = "'#{full_v_name(clear_attr)}'"
		end

		toggle_options.merge! ({
			:"@toggle-event" => "toggle",
			:":val" => "toggles['#{attribute}']",
			:field=> attribute
		})
		@template.content_tag(:toggle, "", toggle_options)
	end


	def objectify_options(options)
	  super.except(:label, :validate, :show_toggle, :"v-show", :show_if, :tooltip, :before_label)
	end

	def tooltip(attribute, key=true, html_options={})
		content =
			key == true ? ActionView::Helpers::Tags::Translator.new(@object, @object_name, attribute, scope: "helpers.tooltip").translate :
				I18n.t(key)
		add_to_class(html_options, "tooltip")
		@template.content_tag :div, html_options do
			@template.content_tag(:div, {class: "tooltip-icon"}) do
				@template.content_tag(:div, "?", {class: "inner"}) +
				@template.content_tag(:div, content, {class: "tooltip-content"})
			end
		end
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
	def add_to_class(args, class_name)
		args[:class] ||= ""
		args[:class] << " " << class_name
	end
	def field_label(attribute, label_opt)
		opts_to_pass = label_opt
		label_key = if label_opt.is_a?(Symbol) || label_opt.is_a?(String)
			opts_to_pass = {}
			label_opt
		elsif label_opt.is_a?(Hash) && label_opt.has_key?(:key)
			label_opt.delete :key
		else
			attribute
		end

  	label(label_key, opts_to_pass)
  end
end
