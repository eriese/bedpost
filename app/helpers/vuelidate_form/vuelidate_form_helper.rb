module VuelidateForm::VuelidateFormHelper
	def vuelidate_form_with(**options)
		prc = block_given? ? Proc.new : nil
		generate_form_using(:form_with, [options], options, prc)
	end

	def vuelidate_form_for(record, options = {}, &block)
		generate_form_using(:form_for, [record, options], options, block)
	end

	private
	def generate_form_using(method, args, options, block)
		form_opts = options.delete(:vue) || {}
		set_options(options)
		form_obj = nil
		stepper_options = options.delete :stepper
		options[:wizard] ||= stepper_options.present?
		form_text = send(method, *args) do |f|
			#grab the form builder during building
			form_obj = f

			#add the errors at the top
			concat(f.form_errors) unless options[:errors] == false
			#do normal building business
			block.call(f) if block
		end

		#wrap in vue component template
		add_valid_form_wrapper(form_obj, form_text, form_opts)
	end

	def set_options(options)
		builder = VuelidateForm::VuelidateFormBuilder
		options[:builder] ||= builder
		options[:html] ||= {}
		options[:html].reverse_merge! ({
			"slot-scope" => "#{builder::SLOT_SCOPE}",
			"@submit" => "#{builder::SLOT_SCOPE}.validateForm",
			"@ajax:error" => "#{builder::SLOT_SCOPE}.handleError",
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
			":error" => flash[:submission_error],
		}.merge(form_opts)) do
			form_text
		end
	end
end
