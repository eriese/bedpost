module ApplicationHelper

	NAV_LINKS = {
		"nav.dashboard" => Rails.application.routes.url_helpers.root_path,
		"nav.user_profile_edit" => Rails.application.routes.url_helpers.edit_user_profile_path
	}

	def pronouns
		Mongoid::QueryCache.cache { Pronoun.all}.to_ary
	end
end
