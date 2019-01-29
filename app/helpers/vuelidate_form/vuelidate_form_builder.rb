module VuelidateForm; class VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	include VuelidateFormUtils

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

  def hidden_field(attribute, options={})
  	options = options.merge({label: false, validate: false})
  	field_builder(attribute, options).field do
  		super
  	end
  end

  def check_box(attribute, args={}, checked_value = "1", unchecked_value = "0")
  	add_to_class(args, "inline", :field_class)
  	field_builder(attribute, args).field do
  		super
  	end
  end

  def toggle(attribute, options={}, toggle_options={})
		add_to_class(options, "inline")
		options[:before_label] = true unless options.has_key?(:before_label)
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
  		super <<
  		@template.content_tag(:noscript) do
  			@template.content_tag(:div, {class: "range-indicator"}) do
  				indicators = ActiveSupport::SafeBuffer.new
  				t_key = "helpers.sliders.#{@object_name}.#{attribute}"
  				[options[:min], options[:max]/2, options[:max]].each do |n| indicators << @template.content_tag(:div, I18n.t(t_key, count: n, default: [:"helpers.sliders"]), class: "indicator")
  				end
	  			indicators
	  		end
  		end <<
  		@template.content_tag(:aside, "{{$root.t('helpers.sliders.#{@object_name}.#{attribute}', {count: #{options[:"v-model"]}, defaults: [{scope: 'helpers.sliders'}]})}}", {id: desc_id, class: "slide-bar-desc js-only", "aria-live" => true})
  	end
  end

  def password_field(attribute, args={})
  	args[:":type"] = "toggles['password']"
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

	def form_errors
		@template.content_tag("form-errors", {:":submission-error" => "submissionError"}) do
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
			opts = html_options.merge({role: "tooltip", :"v-show" => "slot.scope.focused"})
		end
		opts[:id] = "#{attribute}-tooltip-content"
		add_to_class(opts, "tooltip")

		@template.content_tag(:aside, opts) do
			t_key = key == true ? attribute : key;
			ActionView::Helpers::Tags::Translator.new(@object, @object_name, t_key, scope: "helpers.tooltip").translate
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

	def add_validation(attribute)
		@validations ||= []
		@validations << attribute unless @validations.include?(attribute)
	end
end; end
