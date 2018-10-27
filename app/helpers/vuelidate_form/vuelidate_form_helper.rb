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
		set_options(options)
		form_obj = nil
		form_text = send(method, *args) do |f|
			#grab the form builder during building
			form_obj = f

			#add the errors at the top
			concat(f.form_errors) unless options[:errors] == false
			#do normal building business
			block.call(f) if block
		end

		#wrap in vue component template
		add_valid_form_wrapper(form_obj, form_text)
	end

	def set_options(options)
		options[:builder] ||= VuelidateForm::VuelidateFormBuilder
		options[:html] ||= {}
		options[:html][:"@submit"] = "validateForm"
		options[:html][:ref] = "form"
		options[:html][:novalidate] = ""
	end

	def add_valid_form_wrapper(form_obj, form_text)
		validations = form_obj.validations.join(",")
		content_tag("vuelidate-form", {"inline-template" => "", validate: validations}) do
			form_text
		end
	end
end
