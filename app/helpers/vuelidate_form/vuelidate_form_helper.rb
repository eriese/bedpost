module VuelidateForm::VuelidateFormHelper
	def vuelidate_form_for(**options)
		set_options(options) do
			if block_given?
	      form_with(options, &Proc.new)
	    else
	      form_with(options)
	    end
	  end
  end

  def vuelidate_form_for(record, options = {}, &block)
    set_options(options) do
    	form_obj = nil
    	form_text = form_for(record, options) do |f|
    			form_obj = f
					block.call(f)
			end
			add_valid_form_wrapper(form_obj, form_text)
    end
  end

  private def set_options(options, &block)
  	options[:builder] ||= VuelidateForm::VuelidateFormBuilder
		options[:html] ||= {}
		options[:html][:"@submit"] = "validateForm"
		block.call
	end

	def add_valid_form_wrapper(form_obj, form_text)
		validations = form_obj.validations.join(",")
		content_tag("valid-form", {"inline-template" => "", validate: validations}) do
			form_text
		end
	end

end
