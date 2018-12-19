module VuelidateForm
class VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	include VuelidateFormUtils

	attr_reader :validations

	(field_helpers - [:fields_for, :fields, :label, :check_box, :radio_button,  :hidden_field, :password_field]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})  # def text_field(method, options = {})
        field_builder(method, options).field do
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

  def field_builder(attribute, options)
  	VuelidateFieldBuilder.new(attribute, options, self, @template)
  end

  def check_box(attribute, args={}, checked_value = "1", unchecked_value = "0")
  	add_to_class(args, "inline", :field_class)
  	field_builder(attribute, args).field do
  		super
  	end
  end

  def select(attribute, choices = nil, options = {}, html_options=nil, &block)
		html_options ||= options[:html] || {}
		html_options[:label] = options.delete(:label) if html_options[:label].nil?
		html_options[:class] ||= options.delete(:class)
  	field_builder(attribute, html_options).field do
  		super
  	end
  end


  def password_field(attribute, args={})
  	args[":type"] = "toggles['password']"
  	after_method = args[:show_toggle] ? :password_toggle : nil
  	field_builder(attribute, args).field(after_method) do
  		super
  	end
  end

  def password_toggle
  	@template.content_tag(:div, {class: "additional", slot: "additional"}) do
  		@template.content_tag(:p) do
  			toggle_tag(:password, {class: "no-line", :":symbols" => "['hide_password', 'show_password']", :":translate" => true, :":vals" => "['text', 'password']"})
  		end
  	end
  end

  def field(attribute, options = {}, selector = :div, &block)
  	label_opt = options.delete :label
  	tooltip_opt = options.delete :tooltip
  	before_label = options.delete :before_label
  	@template.content_tag(selector, options) do
  		@template.concat block.call if before_label
			@template.concat field_label(attribute, label_opt) unless label_opt == false
  		@template.concat tooltip(attribute, tooltip_opt) if tooltip_opt
  		@template.concat block.call unless before_label
		end
	end

	def field_wrapper(attribute, args = {}, after_method = nil, &block)
		add_ARIA(attribute, args)
		add_v_model(attribute, args)

		field_error_wrapper(attribute, args) do
			field(attribute, get_field_args(attribute, args)) do
				block.call
			end <<
			(send(after_method) unless after_method.nil?)
		end
	end

	def get_field_args(attribute, args={})
		field_args = args.slice :label, :tooltip, :before_label
		if args[:show_if] || args[:"v-show"]
			field_args[:"v-show"] = args[:"v-show"] || full_v_name(args[:show_if])
		end

		field_args[:class] = args.delete :field_class
		field_args[:"slot-scope"] = "slot" unless args[:validate] == false
		add_to_class(field_args, "field") if args[:validate] == false

		return field_args
	end

	def field_error_wrapper(attribute, args, &block)
		unless args[:validate] == false
			err_args = {field: attribute, :":v" => "$v", :":submission-error" => "submissionError"}
			err_args[:"model-name"] = @object_name unless @object_name.blank?
			err_args[:class] = args.delete :field_class
			add_to_class(err_args, "field")
			@template.content_tag(:"field-errors", err_args, &block)
		else
			block.call
		end
	end

	def form_errors
		@template.content_tag("form-errors", {:":submission-error" => "submissionError"}) do
			errors = @template.flash[:submission_error]
			if errors.present?
				@template.content_tag(:noscript) do
					@template.content_tag(:div, {class: "errors"}) do
						delim = I18n.t(:join_delimeter)
						errors.each do |att, errs|
							err_text = errs.join(delim)
							@template.concat(@template.content_tag(:div, err_text, {id: "#{att}-error"}))
						end
					end
				end
			end
		end
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
		t_key = key == true ? attribute : key;
		content = ActionView::Helpers::Tags::Translator.new(@object, @object_name, t_key, scope: "helpers.tooltip").translate
		add_to_class(html_options, "tooltip")
		@template.content_tag :div, html_options do
			@template.content_tag(:div, {class: "tooltip-icon"}) do
				@template.content_tag(:button, "?", {class: "inner not-button", type: "button", role: "tooltip"}) +
				@template.content_tag(:div, content, {class: "tooltip-content", id: "#{attribute}-tooltip-content"})
			end
		end
	end

	def add_validation(attribute)
		@validations ||= []
		@validations << attribute unless @validations.include?(attribute)
	end

	private
	def full_v_name(attribute)
		@object_name.blank? ? "formData.#{attribute}" : "formData.#{@object_name}.#{attribute}"
	end
	def add_v_model(attribute, args={})
		args[:"v-model"] ||= full_v_name attribute
		args[:ref] ||= attribute

		unless args[:validate] == false
			args[:"@blur"] ||= "slot.vField.$touch"
			@validations ||= []
			@validations << attribute
		end
	end
	def add_ARIA(attribute, args)
		desc = args[:"aria-describedby"]
		args[:"aria-describedby"] = "#{desc}-tooltip-content" if desc.is_a? Symbol

		unless args[:validate] == false
			args[:":aria-invalid"] ||= "slot.vField.$invalid && slot.vField.$dirty"
			args[:":aria-required"] ||= "slot.vField.blank !== undefined"
			add_to_class(args, "#{attribute}-error", :"aria-describedby")
		end

		add_to_class(args, "#{attribute}-tooltip-content", :"aria-describedby") if args[:tooltip]
	end
	def field_label(attribute, label_opt)
		opts_to_pass = label_opt
		label_key = if label_opt.is_a?(Symbol) || label_opt.is_a?(String)
			opts_to_pass = {}
			label_opt
		elsif label_opt.is_a?(Hash) && label_opt.has_key?(:key)
			label_opt.delete :key
		else
			opts_to_pass = {}
			attribute
		end

		opts_to_pass[:id] = "#{label_key}-label"

  	label(label_key, opts_to_pass)
  end
end
end
