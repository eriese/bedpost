# a builder for the html of a FieldErrorsComponent to go in the slot of a VuelidateFormComponent
module VuelidateForm; class VuelidateFormBuilder; class VuelidateFieldBuilder
	include VuelidateFormUtils

	# the name of the slot scope for prefixing values
	SLOT_SCOPE = 'sc'

	# options used by the field that will be passed from the input call but shouldn't be passed back
	FIELD_OPTIONS = [:label, :tooltip, :label_last, :validate, :required, :show_if, :"v-show",
		:field_class, :is_step, :step_options, :after_content, :after_method, :after_method_args, :field_options, :field_role, :is_date,
		:slot_scope, :parent_scope, :model_value, :skip_value, :field_id, :lazy, :validators, :in_step
	]

	# the name of the model that the input element is attached to. should always end up as "sc.value" to get the value from the error field
	DEFAULT_MODEL_VALUE = "value"

	# Initialize a field builder
	# @param attribute [Symbol] the attribute the field is form
	# @param options [Hash] field options to be passed back to the nested input
	# @param form_builder [FormBuilder] the form builder calling this field builder
	# @param template [Template] the view template building the form
	def initialize(attribute, options, form_builder, template)
		@attribute = attribute
		@form_builder = form_builder
		@input_options = options

		#easy access
		@template = template
		@object = form_builder.object
		@object_name = @form_builder.object_name

		@options = HashWithIndifferentAccess.new(options.delete(:field_options) || {}).merge(options.extract! *FIELD_OPTIONS)
		do_setup
	end

	# set up all the options needed for the field
	def do_setup
		get_validation
		process_options
	end

	# Generate the standard html for the field
	# @param after_method [Symbol] the name of a method to run on the form or template after the rest of the inner html is generated
	# @param selector [Symbol] the selector for the field wrapper
	# @yieldreturn [ActiveSupport::SafeBuffer] html content to be wrapped by the form field. Usually an input tag from +@form_builder+
	# @return [ActiveSupport::SafeBuffer] the generated html for the form field
	def field(after_method = nil, selector = :div, &block)
		custom_field(after_method, selector) do
			field_inner &block
		end
	end

	# Generate custom html for the field
	# @param (see #field)
	# @param (see #field)
	# @yieldreturn [ActiveSupport::SafeBuffer] html content to be wrapped by the form field. Usually something in addition to an input tag from +@form_builder+
	def custom_field(after_method=nil, selector = :div, &block)
		# add the field's value to the form unless options say not to
		@form_builder.add_value(@attribute) unless @options[:skip_value]
		# grab the after method for later user
		@after_method = after_method if after_method.present?
		# get stepper options
		step_options = @options.delete(:step_options) || {}
		step_options[:exclude_slot] = true
		# build the wizard step first (it won't wrap if this isn't a step)
		@form_builder.step(@is_step, step_options.symbolize_keys) do
			# wrap the field-errors component in the step
			@template.content_tag(:"field-errors", @error_wrapper_options) do
				# wrap the inner wrapper in the component and around the block output
				@template.content_tag(selector, @error_inner_options, &block) <<
				# add the error field for browsers with javascript disabled
				no_js_error_field <<
				# call the after method
				call_after_method
			end
		end
	end

	# Generate the standard html to be wrapped in +#field+
	def field_inner
		output = ActiveSupport::SafeBuffer.new
		#first call the given block
		output << yield if block_given?

		# add the label based on where the options say it should go
		@options[:label_last] ? output << field_label : output.prepend(field_label)
		# add the tooltip
		output << field_tooltip
	end

	# generate the html for an error field for browsers with javascript disabled
	def no_js_error_field
		# don't bother if there aren't wrrors
		if @validate && @sub_error.present?
			# add a noscript tag with the error in it
			@template.content_tag(:noscript) do
				@template.content_tag(:div, @sub_error, {id: "#{@attribute}-error", class: "field-errors"})
			end
		else
			""
		end
	end

	# generate the html of the after method if there is one
	def call_after_method
		#return an empty string if there's no method
		return "" if @after_method.nil?

		# if after_method is actually after_content, return it directly
		return @after_method unless @after_method.is_a? Symbol

		# if the form_builder responds to it, call it on the form_builder
		return @form_builder.send(@after_method) if @form_builder.respond_to?(@after_method)
		# try it on the template
		return @template.send(@after_method, *@after_method_args) if @template.respond_to?(@after_method)

		""
	end

	# generate the label for the field if there is one
	def field_label
		return "" unless @label_options.present?
		@form_builder.label(@label_key, @label_options)
	end

	# generate the tooltip for the field if there is one
	def field_tooltip
		tooltip_opt = @options[:tooltip]
		# if we were given config
		if tooltip_opt.is_a? Hash
			#get the key and options (true uses the attribute name as the key)
			key = tooltip_opt.delete(:key) || true
			html_opts = tooltip_opt
		else
			#otherwise the option is the key
			key = tooltip_opt
			html_opts = {}
		end

		html_opts[:slot_scope] ||= @slot_scope unless html_opts.delete :no_scope

		#generate the html
		@form_builder.tooltip(@attribute, key, html_opts) if key
	end

	private
	# get the options that will be used inside the block call
	def input_options
		# make the descriptions
		desc = @input_options['aria-describedby']
		desc = desc.to_s + '-tooltip-content' if desc.present?
		defaults = {
			# v-model is always sc.model inside the field-errors scope
			'v-model' => "#{@slot_scope}.model",
			# add a reference to this attribute's input for the form component to user
			ref: @attribute,
			# event listeners
			'@blur' => "#{@slot_scope}.onBlur",
			'@focus' => "#{@slot_scope}.onFocus",
			# for input, emit the target value, unless another attribute (like checked) is specified
			'@input' => "#{@slot_scope}.$listeners.input($event.target.#{@options[:model_value] || DEFAULT_MODEL_VALUE})",
			# static aria attributes for progressive enhancement
			aria: {
				required: @required,
				describedby: "#{@attribute}-error #{@object_name}_#{@attribute}-tooltip-content #{desc}".strip,
				invalid: @sub_error.present?
			},
			#dynamic aria attributes
			':aria-required' => "#{@slot_scope}.ariaRequired",
			':aria-invalid' => "#{@slot_scope}.ariaInvalid"
		}.merge(@input_options)

		# if there's a parent scope, add those listeners as well
		defaults.merge!({
			:"@child-focus" => "#{@parent_scope}.onFocus",
			:"@child-blur" => "#{@parent_scope}.onBlur"
		}) if @parent_scope.present?

		defaults['v-model.lazy'] = defaults.delete('v-model') if @options[:lazy]
		defaults
	end

	# get the options for the field-errors component
	def error_wrapper_options
		v_model = @attribute
		submission_error = @attribute.to_s

		# get the nested name for the object in case it's in a form field
		nested_name = @object_name.respond_to?(:gsub) ? @object_name.gsub(']', '').split('[') : [@object_name]
		if nested_name.length == 1
			submission_error = '.' + submission_error
		else
			nested_name.shift
			nested_name << @attribute.to_s
			v_model = nested_name.join('.')

			submission_error = ''
			prev_join = ''
			nested_name.each do |n|
				prev_join += ".#{n}"
				submission_error += " && vf.submissionError#{prev_join}"
			end
		end

		defaults = {
			# v-model is the attribute in the form's formData
			'v-model' => "vf.formData.#{v_model}",
			# the submission error for the attribute
			':submission-error' => "vf.submissionError#{submission_error}",
			# the name of the object being modified by the form, for translation key purposes
			'model-name' => @object_name,
			# classes for the wrapper
			:class => "#{@options[:field_class]} field".strip,
		}
		# if it's a step, slot it into the step
		defaults[:"slot-scope"] = "stepSlot" if @is_step
		# combine input blurs or just add the default
		if @is_step || @in_step
			input_blur = "stepSlot.fieldBlur(...arguments)"
			input_blur += "; #{@options.delete('@input-blur')}" if @options.has_key?('@input-blur')
			input_blur += '()' unless input_blur.ends_with?(')')
			defaults[:"@input-blur"] = input_blur
		end

		# the generated validations for the attribute
		defaults[':v-field'] = "vf.$v.formData#{submission_error.gsub('submissionError', '$v.formData')}"
		#whether this attribute is a date
		defaults[':is-date'] = true if @options[:is_date]
		defaults
	end

	# get the options for the field-errors slot wrapper
	def error_inner_options
		# get v-show
		defaults = (@options.slice(:"v-show") || {}).merge({
			# add the slot scope name
			'slot-scope' => @slot_scope,
			'@focusout' => "#{@slot_scope}.onBlur",
			'@focusin' => "#{@slot_scope}.onFocus"
		})
		# generate v-show from other options if need be
		defaults[:"v-show"] ||= "model.#{options[:show_if]}" if @options[:show_if]
		# add an aria role if given
		defaults[:role] = @options[:field_role] if @options.has_key? :field_role
		defaults[:id] ||= @options[:field_id]
		defaults
	end

	# get the options for the field label
	def label_options
		label_opt = @options[:label]
		# don't do anything if this field shouldn't have a label
		return if label_opt == false

		# tell it if it's required so it can add an aterisk
		defaults = {required: @required}
		# get the label key
		@label_key = if label_opt.is_a?(Symbol) || label_opt.is_a?(String)
			# the option is the key
			label_opt
		elsif label_opt.is_a?(Hash)
			# merge the given options
			defaults.merge!(label_opt)
			# get the key option
			defaults.has_key?("key") ? defaults.delete("key") : @attribute
		else
			# fallback to the attribute name
			@attribute
		end

		# set an id
		defaults[:id] ||= "#{@label_key}#{defaults["value"]}-label"
		defaults
	end

	# process validation for the field
	def get_validation
		validators = @options.delete(:validators) || []

		# if the object being modified exists
		if @object.present?
			# get the class's validations on the attribute
			validators += get_validators

			# if there aren't any but this is a confirmation field, see what there is for the field it confirms
			if validators.empty? && @attribute.to_s.include?("_confirmation")
				other_vals = @object.class.validators_on(@attribute.to_s.chomp("_confirmation"))
				# filter out all but the confirm validator(s)
				validators = filter_validators(:confirm, other_vals, :select)
			end
		end

		# it's required if it's marked required or if all fields are required or if it has a presence validator
		@required = @options.has_key?(:required) ? @options[:required] : (@form_builder.options[:require_all] || filter_validators(:presence, validators))
		# it should validate if it's marked to validate or if it's required or if it has any validations
		@validate = @options.has_key?(:validate) ? @options[:validate] : (@required || validators.any?)

		if @validate
			# get the validators formatted for use by the form if the object has them
			mapped_validators = VuelidateFormUtils.map_validators_for_form(validators, @object, @required)
			# otherwise just send a presence validator if it's required
			if @required && mapped_validators.none? {|v| v[0] == :presence }
				mapped_validators << [:presence]
			end
			# tell the form about the validation
			@form_builder.add_validation(@attribute, mapped_validators) if mapped_validators.any?
		end

		# lastly, get flash errors
		flash_error = @template.flash[:submission_error]
		@sub_error = flash_error[@attribute.to_s] if flash_error.present?
		@sub_error = @sub_error.join(I18n.t(:join_delimeter)) if @sub_error.respond_to? :join
	end

	# process the options to get the various needed configs
	def process_options
		# set the scope names
		@slot_scope = @options.delete(:slot_scope) || SLOT_SCOPE
		@parent_scope = @options.delete(:parent_scope)

		# this is a step if it says it is or the form is a wizard
		@is_step = @options.has_key?(:is_step) ? @options[:is_step] : @form_builder.options[:wizard]
		@in_step = @options.has_key?(:in_step) ? @options[:in_step] : @form_builder.options[:in_wizard]

		# get the after method information
		@after_method = @options.delete(:after_method) || @options.delete(:after_content)
		@after_method_args = @options.delete(:after_method_args)

		#merge in place because this is the options object that's given to the input
		@input_options.reverse_merge!(input_options)
		#get the options for the other parts of the field
		@error_wrapper_options = error_wrapper_options
		@error_inner_options = error_inner_options
		@label_options = label_options
	end


	def get_validators(field=@attribute)
		@object.present? && @object.class.respond_to?(:validators_on) ? @object.class.validators_on(field) : []
	end

	# filter the given list of validators using the given Array method with a type comparison block
	# @param val_type [Class,Symbol] the type of validator to keep
	# @param val_list [Array] a list of validators to filter. if nil, this function will use field to find them
	# @param filter_method [Symbol] the name of the Array method to use
	# @param field [Symbol] the name of the field to get validators for if val_list is nil
	def filter_validators(val_type, val_list=nil, filter_method = :any?, field=@attribute)
		unless val_type.kind_of? Class
			# map the convenience symbols to their intended classes
			val_type = case val_type
			when :presence
				Mongoid::Validatable::PresenceValidator
			when :confirm
				ActiveModel::Validations::ConfirmationValidator
			else
				# that's all the convenience symbols we use for now, so anything else isn't here
				return filter_method == :any? ? false : []
			end
		end

		# get the validators if the list was nil
		val_list ||= get_validators(field)
		# use the filter method with a type check
		val_list.send(filter_method) {|v| v.kind_of? val_type}
	end

end; end; end
