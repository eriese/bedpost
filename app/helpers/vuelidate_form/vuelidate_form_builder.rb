module VuelidateForm; class VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	include VuelidateFormUtils

  SLOT_SCOPE = "vf"

	attr_reader :validations

	(field_helpers - [:fields_for, :fields, :label, :check_box, :hidden_field, :password_field, :range_field]).each do |selector|
    class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
      def #{selector}(method, options = {})  # def text_field(method, options = {})
        field_builder(method, options).field do
        	super
        end
      end                                    # end
    RUBY_EVAL
  end

  def field_builder(attribute, options)
  	VuelidateFieldBuilder.new(attribute, options, self, @template)
  end

  def step(use_step=true, **options)
  	if use_step
      options[:"@step-ready"] ||= "stepper.stepReady"
      options[:":num-steps"] = "stepper.numSteps"
      options[:"aria-role"] = "region"
  		@template.content_tag(:"form-step", options) do
  			yield
  		end
  	else
  		yield
  	end
  end

  def wizard(options = "{}")
    old_wiz_val = @options[:wizard]
    @options[:wizard] = true
    stepper = @template.render "wizard", options: options do
      yield
    end
    @options[:wizard] = old_wiz_val
    return stepper
  end

  def hidden_field(attribute, options={})
  	options = options.merge({label: false, validate: false})
  	field_builder(attribute, options).field do
  		super
  	end
  end

  def check_box(attribute, args={}, checked_value = "1", unchecked_value = "0")
  	add_to_class(args, "inline", :field_class) unless args[:inline] == false
    args[:label_last] = true unless args.has_key? :label_last
    toggle_opt = args.delete :toggle
    if toggle_opt
      toggle_key = toggle_opt == true ? attribute : toggle_opt
      args[:"v-model"] = "#{SLOT_SCOPE}.toggles['#{toggle_key}']"
      add_toggle(toggle_key, args[:checked])
    end
  	field_builder(attribute, args).field do
  		super
  	end
  end

  def toggle(attribute, options={}, toggle_options={})
		add_to_class(options, "inline") unless args[:inline] == false
		options[:label_last] = true unless options.has_key?(:label_last)
		field_builder(attribute, options).field do
			toggle_tag(attribute, toggle_options)
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

  def range_field(attribute, **options)
  	desc_id = "#{attribute}-desc"
  	options[:"aria-describedby"] = desc_id
  	options[:min] ||= 1
  	options[:max] ||= 10
  	field_builder(attribute, options).field do
      @template.render "forms/range_field", options: options, attribute: attribute, object_name: @object_name, desc_id: desc_id, t_key: "helpers.sliders.#{@object_name}.#{attribute}" do
        super
      end
  	end
  end

  def password_field(attribute, args={})
  	args[:":type"] = "#{SLOT_SCOPE}.toggles['password']"
  	after_method = args[:show_toggle] ? :password_toggle : nil
  	field_builder(attribute, args).field(after_method) do
  		super
  	end
  end

  def password_toggle
  	@template.content_tag(:div, {class: "additional", slot: "additional"}) do
  		@template.content_tag(:p) do
  			toggle_tag(:password, {class: "no-line", :":symbols" => "['hide_password', 'show_password']", :":translate" => true, :":vals" => "['text', 'password']", start_val: "password"})
  		end
  	end
  end

	def form_errors
		@template.content_tag("form-errors", {:":submission-error" => "#{SLOT_SCOPE}.submissionError"}) do
			errors = @template.flash[:submission_error]["form_error"] if @template.flash[:submission_error].present?
			if errors.present?
				errors = errors.join(I18n.t(:join_delimeter)) if errors.respond_to? :join
				@template.content_tag(:noscript) do
					@template.content_tag(:div, errors, {class: "errors"})
				end
			end
		end
	end

	def tooltip(attribute, key=true, html_options={})
		show_always = html_options.delete :show_always
		if show_always
			opts = html_options
			add_to_class(opts, "show-always")
		else
			opts = html_options.merge({role: "tooltip", :"v-show" => "fe.focused"})
		end
		opts[:id] = "#{attribute}-tooltip-content"
		add_to_class(opts, "tooltip")

		@template.content_tag(:aside, opts) do
			t_key = key == true ? attribute : key;
			ActionView::Helpers::Tags::Translator.new(@object, @object_name, t_key, scope: "helpers.tooltip").translate
		end
	end

	def toggle_tag(attribute, **toggle_options)
		clear_opt = toggle_options.delete :":clear"
		if clear_opt
			clear_attr = clear_opt == true ? attribute : clear_opt
			toggle_options[:":clear"] = "'#{full_v_name(clear_attr, false)}'"
		end

		toggle_options.reverse_merge! ({
			:"@toggle-event" => "#{SLOT_SCOPE}.toggle",
			:":val" => "#{SLOT_SCOPE}.toggles['#{attribute}']",
			:field=> attribute
		})

    add_toggle(attribute, toggle_options.delete(:start_val))
    content = ""
    if toggle_options.delete(:js_backup)
      if toggle_options.has_key?(:symbols)
        content = toggle_options[:symbols]
      elsif toggle_options.has_key?(:":symbols")
        content = toggle_options[:":symbols"][0]
      end
    end
		@template.content_tag(:toggle, content, toggle_options)
	end

	def objectify_options(options)
	  super.except(:label, :validate, :show_toggle, :"v-show", :show_if, :tooltip, :label_last, :is_step)
	end

	def add_validation(attribute)
		@validations ||= []
		@validations << attribute unless @validations.include?(attribute)
	end

  def add_toggle(attribute, start_val)
    toggles[attribute] = start_val || false unless toggles.has_key? attribute
  end

  def toggles
    @toggles ||= @options.delete(:toggles) || {}
  end
end; end
