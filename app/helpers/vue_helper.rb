module VueHelper
	def confirm_link_to(label, path, **options)
		configure_confirm(options) + link_to(label, path, options)
	end

	def confirm_button_to(label, path, **options)
		configure_confirm(options) + button_to(label, path, options)
	end

	private
	def configure_confirm(options)
		options[:data] ||= {}
		options[:data][:confirm] ||= t(".confirm")
		options[:id] ||= SecureRandom.urlsafe_base64
		options[:"@blur"] = "cancelConfirm('#{options[:id]}')"
		unless options.delete(:alert) == false
			alert_el = options.delete(:alert_el) || :span
			output = content_tag(alert_el, "", role: alert, class: options.delete(:alert_class), :"v-html" => "confirmations['#{options[:id]}']")
		else
			""
		end
	end
end
