module ApplicationHelper

	NAV_LINKS = {
		"nav.dashboard" => Rails.application.routes.url_helpers.root_path,
		"nav.user_profile_edit" => Rails.application.routes.url_helpers.edit_user_profile_path
	}

	def pronouns
		Mongoid::QueryCache.cache { Pronoun.all}.to_ary
	end

	def t_action(key, options={})
		options = options.dup
		default = Array(options.delete(:default)).compact

		ac = controller.action_name
		prefixes = controller.lookup_context.prefixes
		new_default = prefixes.map { |pr| "#{pr}.#{ac}#{key}".to_sym} + default

		new_key = new_default.shift
		options[:default] = new_default
		I18n.t(new_key, options)
	end
end
