module VuelidateForm; class VuelidateFormBuilder; class VuelidateFieldBuilder

	include VuelidateFormUtils

	FIELD_OPTIONS = [:label, :tooltip, :label_last, :validate, :required, :show_if, :"v-show",
		:field_class, :is_step, :step_options, :after_content, :after_method, :after_method_args]

	def initialize(attribute, options, formBuilder, template)
		@attribute = attribute
		@formBuilder = formBuilder
		@external_options = options

		#easy access
		@template = template
		@object = formBuilder.object
		@object_name = @formBuilder.object_name

		@options = options.extract! *FIELD_OPTIONS
		do_setup
	end

	def field(after_method = nil, selector=:div, &block)
		@after_method = after_method if after_method.present?
		output = @formBuilder.step(@options[:is_step], @options.delete(:step_options) || {}) do
			@template.content_tag(:"field-errors", @err_args) do
				@template.content_tag(selector, @field_args) do
					field_inner &block
				end <<
				no_js_error_field <<
				call_after_method
			end
		end

		@formBuilder.add_validation(@attribute) if @validate

		output
	end

	private
	def field_inner
		output = ActiveSupport::SafeBuffer.new

		output << field_tooltip
		output << yield if block_given?

		@options[:label_last] ? output << field_label : output.prepend(field_label)
	end

	def no_js_error_field
		if @validate && @sub_error.present?
			@template.content_tag(:noscript) do
				@template.content_tag(:div, @sub_error, {id: "#{@attribute}-error", class: "field-errors"})
			end
		else
			""
		end
	end

	def call_after_method
		return "" if @after_method.nil?

		return @formBuilder.send(@after_method) if @formBuilder.respond_to?(@after_method)

		return @template.send(@after_method, *@after_method_args) if @template.respond_to?(@after_method)

		""
	end

	def get_validation
		validators = []

		if @object.present?
			validators = @object.class.validators_on(@attribute)

			if validators.empty? && @attribute.to_s.include?("_confirmation")
				other_vals = @object.class.validators_on(@attribute.to_s.chomp("_confirmation"))
				validators = other_vals if filter_validators(:confirm, other_vals)
			end
		end

		@required = @options.has_key?(:required) ? @options[:required] : (@formBuilder.options[:require_all] || filter_validators(:presence, validators))
		@validate = @options.has_key?(:validate) ? @options[:validate] : (@required || validators.any?)

		flash_error = @template.flash[:submission_error]
		@sub_error = flash_error[@attribute.to_s] if flash_error.present?
		@sub_error = @sub_error.join(I18n.t(:join_delimeter)) if @sub_error.respond_to? :join
	end

	def process_options
		@options[:is_step] = @formBuilder.options[:wizard] unless @options.has_key? :is_step
		@after_method = @options.delete(:after_method) || @options.delete(:after_content)
		@after_method_args = @options.delete(:after_method_args)

		field_class = (@options[:field_class] || "") << " field"
		field_class.strip!

		@field_args = @options.slice :"v-show"
		@field_args[:"slot-scope"] = "slot"
		@field_args[:"v-show"] = full_v_name(@options[:show_if]) if @options[:show_if]

		@err_args = {
			field: @attribute,
			:":v" => "$v",
			:":submission-error" => "submissionError",
			:class => field_class,
			:":validate" => @validate
		}
		@err_args[:"model-name"] = @formBuilder.object_name unless @formBuilder.object_name.blank?

		@err_args.merge({:"@input-blur"=> "stepSlot.fieldBlur", :"slot-scope"=> "stepSlot"}) if @options[:is_step]
	end

	def do_setup
		get_validation
		process_options
		add_ARIA
		add_v_model
	end

	def field_label
		label_opt = @options[:label]
		return "" if label_opt == false

		opts_to_pass = {required: @required}
		label_key = if label_opt.is_a?(Symbol) || label_opt.is_a?(String)
			label_opt
		elsif label_opt.is_a?(Hash)
			opts_to_pass = label_opt
			label_opt.has_key?(:key) ? label_opt.delete(:key) : @attribute
		else
			@attribute
		end

		opts_to_pass[:id] ||= "#{label_key}-label"
		@external_options[:label] = opts_to_pass[:id]
		@formBuilder.label(label_key, opts_to_pass)
	end

	def field_tooltip
		tooltip_opt = @options[:tooltip]
		if tooltip_opt.is_a? Hash
			key = tooltip_opt.delete(:key) || true
			html_opts = tooltip_opt
		else
			key = tooltip_opt
			html_opts = {}
		end
		@formBuilder.tooltip(@attribute, key, html_opts) if key
	end

	def add_ARIA
		desc = @external_options[:"aria-describedby"]
		set_external(:"aria-describedby", "#{desc}-tooltip-content", false) if desc.is_a? Symbol

		if @validate
			set_external(:":aria-invalid", "slot.scope.ariaInvalid")
			sub_error = @template.flash[:submission_error]
			set_external(:"aria-invalid", @sub_error.present?)

			set_external(:":aria-required", "slot.scope.ariaRequired")
			set_external(:"aria-required", @required)
			add_to_class(@external_options, "#{@attribute}-error", :"aria-describedby", true)
		end

		add_to_class(@external_options, "#{@attribute}-tooltip-content", :"aria-describedby") if @options[:tooltip]
	end

	def add_v_model
		set_external(:"v-model", full_v_name)
		set_external(:ref, @attribute)
		set_external(:@blur, "slot.scope.onBlur")
		set_external(:@focus, "slot.scope.onFocus")
	end

	def add_on(key, addition, add_to_front=false)
		add_to_class(@options, addition, key, add_to_front)
	end

	def set_external(key, value, only_if_absent=true)
		if only_if_absent
			@external_options[key] ||= value
		else
			@external_options[key] = value
		end
	end

	def filter_validators(val_type, val_list=nil, filt = :any?, field=@attribute)
		return false if @object.nil?
		unless val_type.kind_of? Class
			val_type = case val_type
			when :presence
				Mongoid::Validatable::PresenceValidator
			when :confirm
				ActiveModel::Validations::ConfirmationValidator
			else
				return filt == :any? ? false : []
			end
		end

		val_list ||= @object.class.validators_on(field)
		val_list.send(filt) {|v| v.kind_of? val_type}
	end
end; end; end
