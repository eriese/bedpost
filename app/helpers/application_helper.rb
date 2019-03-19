module ApplicationHelper
	include VueHelper

	private
	def self.url_helpers
		Rails.application.routes.url_helpers
	end

	public
	NAV_LINKS = {
		"nav.dashboard" => url_helpers.root_path,
		"nav.user_profile_edit" => url_helpers.edit_user_profile_path,
		"nav.partners" => url_helpers.partnerships_path
	}

	def pronouns
		Pronoun.list
	end

	def display_model(model_or_hash)
		els = []
		if model_or_hash.is_a? Array
			els = model_or_hash.map {|i| display_model(i)}
		else
			fields = model_or_hash
			trans_proc = nil
			unless model_or_hash.is_a? Hash
				fields = model_or_hash.class.respond_to?(:display_fields) ? model_or_hash.class.display_fields : model_or_hash.attribute_names
				trans_proc = Proc.new {|k| model_or_hash.class.human_attribute_name(k)}
			else
				trans_proc = Proc.new {|k| k}
			end


			els = fields.map do |f|
				val = model_or_hash.send(f);
				if val.is_a?(Array) && (val[0].is_a?(ActiveModel::Model) || val[0].is_a?(Hash))
					display_model(val)
				else
					display_val =  val.display || val
					content_tag(:div, t(".field_html", {field: trans_proc.call(f), value: display_val}))
				end
			end
		end

		content_tag(:div, safe_join(els))
	end

	def t_action(key, **options)
		options = options.dup
		default = Array(options.delete(:default)).compact

		ac = controller.action_name
		prefixes = controller.lookup_context.prefixes
		new_default = prefixes.map { |pr| "#{pr}.#{ac}#{key}".to_sym} + default

		new_key = new_default.shift
		options[:default] = new_default
		t(new_key, options)
	end
end
