module ApplicationHelper
	include VueHelper

	THEME_REGEX = /(^|\s)is-(dark|light)(-contrast)?(\s|$)/

	private
	def self.url_helpers
		Rails.application.routes.url_helpers
	end

	public
	NAV_LINKS = {
		"nav.dashboard" => url_helpers.root_path,
		"nav.user_profile_edit" => url_helpers.edit_user_profile_registration_path,
		"nav.partners" => url_helpers.partnerships_path,
		"nav.encounters" => url_helpers.encounters_path
	}

	def pronouns
		Pronoun.list
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

	def body_class(clss = nil)
		if clss.nil?
			content = content_for :body_class
			body_class('is-light') unless content.match(THEME_REGEX)
			return content_for :body_class
		end

		content_for(:body_class, ' ') if content_for? :body_class
		content_for :body_class, clss
	end

	def theme
		body_class.match(THEME_REGEX)[0].strip
	end

	def analytics_id
		return nil if user_profile_signed_in? && !current_user_profile.opt_in

		# TODO: use an ENV variable for this
		if Rails.env.development? || Rails.env.test?
			'UA-156331784-2'
		elsif ENV['IS_STAGING']
			'UA-156331784-4'
		else
			'UA-156331784-3'
		end
	end
end
