module VuelidateForm; class VuelidateFormBuilder; class VuelidateFieldBuilder

	include VuelidateFormUtils
	include ActionView::Helpers::TagHelper

	FIELD_OPTIONS = [:label, :tooltip, :before_label, :validate, :required, :show_if, :"v-show",
		:field_class]

	def initialize(attribute, options, formBuilder, template)
		@attribute = attribute
		@formBuilder = formBuilder
		@external_options = options

		#easy access
		@template = template
		@object = formBuilder.object

		@options = options.extract! *FIELD_OPTIONS
		do_setup
	end

	def field(after_method = nil, selector=:div, &block)
		output = @template.capture do
			@template.content_tag(selector, @field_args) do
				field_inner &block
			end
		end

		output << @formBuilder.send(after_method) unless after_method.nil?

		if @validate
			output = @template.content_tag(:"field-errors", output, @err_args)
			@formBuilder.add_validation(@attribute)
		end

		output
	end

	def field_inner
		output = ActiveSupport::SafeBuffer.new
		output << field_label

		tooltip_opt = @options[:tooltip]
		output << @formBuilder.tooltip(@attribute, tooltip_opt) if tooltip_opt

		inner = block_given? ? yield : ""
		@options[:before_label] ? output.prepend(inner) : output << inner
	end

	private
	def process_options
		validators = @object.present? ? @object.class.validators_on(@attribute) : []

		if @object.present? && @attribute.to_s.include?("_confirmation")
			other_vals = @object.class.validators_on(@attribute.to_s.chomp("_confirmation"))
			validators = filter_validators(ActiveModel::Validations::ConfirmationValidator,other_vals, :select)
			@required = filter_validators(Mongoid::Validatable::PresenceValidator, other_vals, :any?)
		end

		@validate = @options[:validate] == true || @options[:required] == true || (@options[:validate] != false && validators.any?)
		@required ||= @options[:required].nil? ? filter_validators(Mongoid::Validatable::PresenceValidator, validators) : @options[:required]
		field_class = (@options[:field_class] || "") << " field"
		field_class.strip!

		@field_args = @options.slice :"v-show"
		@field_args[:"v-show"] = full_v_name(@options[:show_if]) if @options[:show_if]

		if @validate
			@field_args[:"slot-scope"] = "slot"

			@err_args = {
				field: @attribute,
				:":v" => "$v",
				:":submission-error" => "submissionError",
				:class => field_class
			}
			@err_args[:"model-name"] = @formBuilder.object_name unless @formBuilder.object_name.blank?
		else
			@field_args[:class] = field_class
		end
	end

	def filter_validators(val_type, val_list=nil, filt = :any?, field=@attribute)
		return false if @object.nil?
		val_list ||= @object.class.validators_on(field)
		val_list.send(filt) {|v| v.kind_of? val_type}
	end

	def do_setup
		process_options
		add_ARIA
		add_v_model

	end

	def field_label
		label_opt = @options[:label]
		return "" if label_opt == false

		opts_to_pass = {}
		label_key = if label_opt.is_a?(Symbol) || label_opt.is_a?(String)
			label_opt
		elsif label_opt.is_a?(Hash)
			opts_to_pass = label_opt
			label_opt.has_key?(:key) ? label_opt.delete(:key) : @attribute
		else
			@attribute
		end

		opts_to_pass[:id] ||= "#{label_key}-label"
		@formBuilder.label(label_key, opts_to_pass)
	end

	def add_ARIA
		desc = @external_options[:"aria-describedby"]
		set_external(:"aria-describedby", "#{desc}-tooltip-content", false) if desc.is_a? Symbol

		if @validate
			set_external(:":aria-invalid", "slot.vField.$invalid && slot.vField.$dirty")
			sub_error = @template.flash[:submission_error]
			set_external(:"aria-invalid", sub_error.present? && sub_error[@attribute].any?)

			set_external(:":aria-required", "slot.vField.blank !== undefined")
			set_external(:"aria-required", @required)
			add_to_class(@external_options, "#{@attribute}-error", :"aria-describedby", true)
		end

		add_to_class(@external_options, "#{@attribute}-tooltip-content", :"aria-describedby") if @options[:tooltip]
	end

	def add_v_model
		set_external(:"v-model", full_v_name)
		set_external(:ref, @attribute)
		set_external(:@blur, "slot.vField.$touch") if @validate
	end

	def full_v_name(attribute=@attribute)
		@formBuilder.object_name.blank? ? "formData.#{attribute}" : "formData.#{@formBuilder.object_name}.#{attribute}"
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
end; end; end
