module VuelidateForm::VuelidateFormHelper
	def vuelidate_form_with(**options, &block)

		generate_form_using(Proc.new do|blc|
			form_with(**options, &blc)
		end, block, options)
	end

	def vuelidate_form_for(record, **options, &block)
		generate_form_using(Proc.new { |blc|form_for(record, **options, &blc)}, block, options)
	end

	private
	def generate_form_using(mtd_call, block, options)
		form_opts = process_options(options)
		form_obj = nil
		blc = Proc.new do|f|
			#grab the form builder during building
			form_obj = f

			#add the errors at the top
			concat(f.form_errors) unless options[:errors] == false
			#do normal building business
			block.call(f) if block
		end
		form_text = mtd_call.call(blc)

		#wrap in vue component template
		add_valid_form_wrapper(form_obj, form_text, form_opts)
	end

	def process_options(options)
		form_opts = (options.delete(:vue) || {}).with_indifferent_access
		form_opts['name'] = options.delete(:name) if options.has_key? :name
		stepper_options = options.delete :stepper
		options[:wizard] ||= stepper_options.present?
		set_options(options)
		form_opts
	end

	def set_options(options)
		builder = VuelidateForm::VuelidateFormBuilder
		options[:builder] ||= builder
		options[:html] ||= {}
		options[:html].reverse_merge! ({
			"slot-scope" => "#{builder::SLOT_SCOPE}",
			"@submit" => "#{builder::SLOT_SCOPE}.validateForm",
			"@ajax:error" => "#{builder::SLOT_SCOPE}.handleError",
			"@ajax:success" => "#{builder::SLOT_SCOPE}.handleSuccess",
			"novalidate" => "",
			"data-type" => "json"
		})
		options[:html][:autocomplete] = "off" unless options[:autocomplete]
	end

	def add_valid_form_wrapper(form_obj, form_text, form_opts)
		validations = form_obj.validations.to_json
		toggles = form_obj.toggles.to_json
		content_tag("vuelidate-form", {
			":validate" => form_obj.validations.to_json,
			":start-toggles" => form_obj.toggles.to_json,
			":value" => form_obj.value.to_json,
			":error" => (flash[:submission_error] || {}).to_json,
			"name" => form_obj.form_name
		}.merge(form_opts)) do
			form_text
		end
	end
end
