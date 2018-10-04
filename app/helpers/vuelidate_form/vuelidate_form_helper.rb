module VuelidateForm::VuelidateFormHelper
	def vuelidate_form_for(**options)
		set_options(options)
		if block_given?
      form_with(options, &Proc.new)
    else
      form_with(options)
    end
  end

  def vuelidate_form_for(record, options = {}, &block)
    set_options(options)
    form_for(record, options, &block)
  end

  private def set_options(options)
  	options[:builder] ||= VuelidateForm::VuelidateFormBuilder
		options[:html] ||= {}
		options[:html][:"@submit"] = "validateForm"
	end
end
