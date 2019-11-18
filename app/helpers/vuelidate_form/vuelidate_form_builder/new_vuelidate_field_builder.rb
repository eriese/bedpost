module VuelidateForm; class VuelidateFormBuilder; class NewVuelidateFieldBuilder
	include VuelidateFormUtils

	SLOT_SCOPE = 'sc'

	FIELD_OPTIONS = [:label, :tooltip, :label_last, :validate, :required, :show_if, :"v-show",
		:field_class, :is_step, :step_options, :after_content, :after_method, :after_method_args, :field_options, :field_role, :is_date,
		:slot_scope, :parent_scope, :model_value
	]

	DEFAULT_MODEL_VALUE = "value"

	def initialize(attribute, options, formBuilder, template)
		@attribute = attribute
		@formBuilder = formBuilder
		@input_options = options

		#easy access
		@template = template
		@object = formBuilder.object
		@object_name = @formBuilder.object_name

		@options = (options.delete(:field_options) || {}).merge(options.extract! *FIELD_OPTIONS)
		do_setup
	end

	def do_setup
		get_validation
		process_options
	end

	def field(after_method = nil, selector = :div, &block)
		@after_method = after_method
		custom_field do
			field_inner &block
		end
	end

	def custom_field(after_method=nil, selector = :div, &block)
		@formBuilder.add_value(@attribute)
		@after_method = after_method if after_method.present?

		@formBuilder.step(@is_step, @options.delete(:step_options) || {}) do
			@template.content_tag(:"field-errors", @error_wrapper_options) do
				@template.content_tag(selector, @error_inner_options, &block) <<
				no_js_error_field <<
				call_after_method
			end
		end
	end

	def field_inner
		output = ActiveSupport::SafeBuffer.new

		output << yield if block_given?

		@options[:label_last] ? output << field_label : output.prepend(field_label)
		output << field_tooltip
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

	def field_label
		return "" unless @label_options.present?
		@formBuilder.label(@label_key, @label_options)
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

	private
	def input_options
		defaults = {
			'v-model' => "#{@slot_scope}.model",
			ref: @attribute,
			'@blur' => "#{@slot_scope}.onBlur",
			'@focus' => "#{@slot_scope}.onFocus",
			'@input' => "#{@slot_scope}.$listeners.input($event.target.#{@options[:model_value] || DEFAULT_MODEL_VALUE})",
			aria: {
				required: @required,
				describedby: "#{@attribute}-error #{@attribute}-tooltip-content #{@input_options['aria-describedby']}".strip,
				invalid: @sub_error.present?
			},
			':aria-required' => "#{@slot_scope}.ariaRequired",
			':aria-invalid' => "#{@slot_scope}.ariaInvalid"
		}.merge(@input_options)

		defaults.merge!({:"@child-focus" => "#{@parent_scope}.onFocus", :"@child-blur" => "#{@parent_scope}.onBlur"}) if @parent_scope.present?
		defaults
	end

	def error_wrapper_options
		defaults = {
			'v-model' => "vf.formData.#{@attribute}",
			':submission-error' => "vf.submissionError.#{@attribute}",
			'model-name' => @object_name,
			:class => "#{@options[:field_class]} field".strip,
		}
		defaults.merge!({:"@input-blur"=> "stepSlot.fieldBlur", :"slot-scope"=> "stepSlot"}) if @is_step
		defaults[':v-field'] = "vf.$v.formData.#{@attribute}"
		defaults[':is-date'] = true if @options[:is_date]
		defaults
	end

	def error_inner_options
		defaults = @options.slice[:"v-show"] || {}.merge({
			'slot-scope' => @slot_scope,
		})
		defaults[:"v-show"] = "model.#{options[:show_if]}" if @options[:show_if]
		defaults[:role] = @options[:field_role] if @options.has_key? :field_role
		defaults
	end

	def label_options
		label_opt = @options[:label]
		return if label_opt == false

		defaults = {required: @required}
		@label_key = if label_opt.is_a?(Symbol) || label_opt.is_a?(String)
			label_opt
		elsif label_opt.is_a?(Hash)
			defaults.merge!(label_opt)
			defaults.has_key?(:key) ? defaults.delete(:key) : @attribute
		else
			@attribute
		end

		defaults[:id] ||= "#{@label_key}#{defaults[:value]}-label"
		defaults
	end

	def get_validation
		validators = []

		if @object.present?
			validators = @object.class.validators_on(@attribute)

			if validators.empty? && @attribute.to_s.include?("_confirmation")
				other_vals = @object.class.validators_on(@attribute.to_s.chomp("_confirmation"))
				validators = filter_validators(:confirm, other_vals)
			end
		end

		@required = @options.has_key?(:required) ? @options[:required] : (@formBuilder.options[:require_all] || filter_validators(:presence, validators))
		@validate = @options.has_key?(:validate) ? @options[:validate] : (@required || validators.any?)

		if @validate
			mapped_validators = VuelidateFormUtils.map_validators_for_form(validators, @object)
			@formBuilder.add_validation(@attribute, mapped_validators)
		end

		flash_error = @template.flash[:submission_error]
		@sub_error = flash_error[@attribute.to_s] if flash_error.present?
		@sub_error = @sub_error.join(I18n.t(:join_delimeter)) if @sub_error.respond_to? :join
	end

	def process_options
		@slot_scope = @options.delete(:slot_scope) || SLOT_SCOPE
		@parent_scope = @options.delete(:parent_scope)

		@is_step = @formBuilder.options[:wizard] unless @options.has_key? :is_step

		@after_method = @options.delete(:after_method) || @options.delete(:after_content)
		@after_method_args = @options.delete(:after_method_args)

		#merge in place because this is the options object that's given to the input
		@input_options.reverse_merge!(input_options)
		#get the options for the other parts of the field
		@error_wrapper_options = error_wrapper_options
		@error_inner_options = error_inner_options
		@label_options = label_options
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
