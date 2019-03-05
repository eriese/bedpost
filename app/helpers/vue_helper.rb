module VueHelper
	def confirm_link_to(label, path, **options)
		options[:data] ||= {}
		options[:data][:confirm] ||= t(".confirm")
		options[:id] ||= SecureRandom.urlsafe_base64
		options[:"@blur"] = "cancelConfirm('#{options[:id]}')"

		output = link_to(label, path, options)
		unless options.delete(:alert) == false
			alert_el = options.delete(:alert_el) || :span
			output = content_tag(alert_el, "", role: alert, class: options.delete(:alert_class), :"v-html" => "confirmations['#{options[:id]}']") + output
		end

		output
	end
end
