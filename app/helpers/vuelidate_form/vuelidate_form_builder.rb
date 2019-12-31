# a field builder to generate the expected html for use with the vue component VuelidateFormComponent while making use of rails form helpers
module VuelidateForm; class VuelidateFormBuilder < ActionView::Helpers::FormBuilder

	include VuelidateFormUtils

	SLOT_SCOPE = "vf"

	def initialize(object_name, object, template, options)
		super
		# if any values that haven't automatically been added by form fields are needed, add them
		return unless value_include = options[:value_include]
		value_include.each do |v|
			case v
			when Symbol
				add_value(v)
			when Hash
				v.each {|k, vv| add_value(k, vv)}
			end
		end
	end

	alias_method :parent_hidden_field, :hidden_field
	alias_method :parent_submit, :submit

	(field_helpers - [:fields_for, :fields, :label, :check_box, :hidden_field, :password_field, :range_field, :file_field]).each do |selector|
		class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
			alias_method :parent_#{selector}, :#{selector}
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
				unless options.delete(:exclude_slot)
					@template.content_tag(:div, 'slot-scope' => 'stepSlot') do
						yield
					end
				else
					yield
				end
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
		options = options.merge({label: false, validate: false, field_class: "hidden-field"})
		field_builder(attribute, options).field do
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

	# TODO this has full_v_name, which doesn't exist anymore
	def get_toggle_options(attribute, options, value)
		toggle_opt = options.delete :toggle
		if toggle_opt
			toggle_key = toggle_opt == true ? attribute : toggle_opt
			options[:"v-model"] ||= "#{SLOT_SCOPE}.toggles['#{toggle_key}']"
			start_val = options.has_key?(:checked) ? options[:checked] : @object.send(attribute)
			add_toggle(toggle_key, start_val)

			clear_opt = options[:clear]
			if clear_opt
				clear_attr = clear_opt == true ? attribute : clear_opt
				clear_attr = full_v_name(clear_attr, false)
				clear_val = value.is_a?(String) ? "'#{value}'" : value
				options[:"@change"] = "#{SLOT_SCOPE}.toggle('#{toggle_key}', #{clear_val}, '#{clear_attr}')"
			end
		end
	end

	def submit(value = nil, options = {})
		@template.content_tag(:div, super, {class: 'buttons'})
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

	def radio_button(attribute, value, options={})
		add_to_class(options, "inline", :field_class) unless options[:inline] == false
		options[:label_last] = true unless options.has_key? :label_last
		get_toggle_options(attribute, options, value)
		field_builder(attribute, options).field do
			super
		end
	end

	def radio_group(attribute, buttons: [[true], [false]], options: {})
		group_scope = 'fe'
		group_opts = (options.delete(:group_options) || {}).reverse_merge(
			field_role: :radiogroup,
			slot_scope: group_scope,
			field_id: "#{@object_name}_#{attribute}_group",
			skip_value: true
		)

		radio_opts = {
			inline: true,
			validate: false,
			class: options.delete(:radio_class),
			slot_scope: 'fec',
			parent_scope: group_scope,
			skip_value: true,
			'aria-describedby' => group_opts[:field_id]
		}

		radio_opts[:label_last] = options.delete(:label_last) if options.has_key? :label_last
		checked_val = options.has_key?(:checked_val) ? options[:checked_val] : @object.present? ? @object[attribute] : nil
		checked_val ||= false

		joiner = options.delete(:joiner)
		builder = field_builder("#{attribute}_group", group_opts)

		btns = buttons.map do |btn|
			val = btn[0]
			opts = radio_opts.merge(
				label: { value: val.to_s },
				checked: checked_val == val,
				':value' => val
			).merge(btn[1] || {})
			radio_button(attribute, val, opts)
		end

		add_value(attribute, checked_val)
		builder.custom_field do
			@template.content_tag(:div) do
				builder.field_label <<
				@template.content_tag(:div, @template.safe_join(btns, joiner), {class: "group-radios"})
			end <<
			builder.field_tooltip
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
		options = convert_options(options)
		desc_id = "#{attribute}-desc"
		options["aria-describedby"] = desc_id
		options[:min] ||= options[:in].min
		options[:max] ||= options[:in].max
		field_builder(attribute, options).field do
			@template.render "forms/range_field", options: options, attribute: attribute, object_name: @object_name, desc_id: desc_id, t_key: "helpers.sliders.#{@object_name}.#{attribute}" do
				super
			end
		end
	end

	def password_field(attribute, args={})
		options = convert_options(options)
		args[:":type"] = "#{SLOT_SCOPE}.toggles['password']"
		after_method = args[:show_toggle] ? :password_toggle : nil
		field_builder(attribute, args).field(after_method) do
			super
		end
	end

	def date_field(attribute, **options)
		options = convert_options(options)
		options[:is_date] = true
		options[:id] = "#{attribute}_visible"
		date_field_builder = field_builder(attribute, options)
		date_field_builder.field do
			mdl = options.delete "v-model"
			@template.content_tag(:"v-date-picker", "", {":value" => mdl, "v-on" => "#{date_field_builder.slot_scope}.$listeners", ":popover" => "{visibility: 'focus'}", ref: "datepicker"}) do
				options[:"slot-scope"] = 'dp'
				options[:"v-bind"] = 'dp.inputProps'
				options[:"v-on"] = 'dp.inputEvents'
				parent_text_field(attribute, options)
			end <<
			parent_hidden_field(attribute, {:"v-model"=> mdl})
		end
	end

	def file_field(attribute, **options)
		options = convert_options(options)
		field_builder(attribute, options).field do
			v_model_name = options.delete 'v-model'
			options['@change'] = "#{v_model_name} = $event.target.files"
			super
		end
	end


	def fields_for(record_name, record_object = nil, options = {}, &block)
		options[:parent_builder] = self
		options[:in_wizard] = @options[:wizard] if @options.has_key? :wizard
		super
	end

	def password_toggle
		@template.content_tag(:div, {class: "additional", slot: "additional"}) do
			@template.content_tag(:p) do
				toggle_tag(:password, {class: "link link--no-line", :":symbols" => "['hide_password', 'show_password']", :":translate" => true, :":vals" => "['text', 'password']", start_val: "password"})
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
		html_options[:key] = key
		html_options[:object] = @object
		Tags::Tooltip.new(@object_name, attribute, @template, html_options).render
	end

	# TODO this has full_v_name, which doesn't exist anymore
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
		super.except(:label, :validate, :show_toggle, :"v-show", :show_if, :tooltip, :label_last, :is_step, :parent_builder)
	end

	# get the validations that will be run on data from this form
	def validations
		@validations ||= Hash.new { |hsh, key| hsh[key] = []}
	end

	#add validations for the given attribute
	def add_validation(attribute, attr_validators)
		validations[attribute].concat(attr_validators)
		@options[:parent_builder].add_nested(validations, @object_name, :validations) if @options[:parent_builder]
	end

	# get the values of fields in this form
	def value
		@value ||= {}
	end

	# add a field value to the form
	def add_value(attribute, attr_value = nil)
		if attr_value.nil?
			attr_value = @object.respond_to?(attribute) ? @object.send(attribute) : nil
		end
		value[attribute] = attr_value

		@options[:parent_builder].add_nested(value, @object_name, :value) if @options[:parent_builder]
	end

	# add nested values to the hash with the given name
	def add_nested(nested_values = {}, nested_name, hash_name)
		# get the correct hash
		hsh = send(hash_name)
		# make the key by stripping all but the last part of the object name
		nested_key = nested_name.gsub(/(.*\[)|(\])/, '')
		# the key should map to a hash regardless of which hash it's in
		hsh[nested_key] = {} unless hsh.has_key?(nested_key) && hsh[nested_key].is_a?(Hash)
		# merge in the values
		hsh[nested_key].merge!(nested_values)
	end

	# add a toggle field and its starting value to the form
	def add_toggle(attribute, start_val)
		if @options[:parent_builder]
			@options[:parent_builder].add_toggle(attribute, start_val)
			return
		end
		toggles[attribute] = start_val || false unless toggles.has_key? attribute
	end

	# get the toggles on this form
	def toggles
		@toggles ||= @options.delete(:toggles) || {}
	end

	# convert options into a HashWithIndifferentAccess for easier key access
	# @note we do this here so that the same object is passed to the field builder for processing as is passed to the parent method for input generating
	def convert_options(options)
		HashWithIndifferentAccess.new(options)
	end
end; end
