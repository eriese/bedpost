module ApplicationHelper
	NAV_LINKS = {
		"dashboard" => Rails.application.routes.url_helpers.root_path,
		"user_profile.edit" => Rails.application.routes.url_helpers.edit_user_profile_path,
	}
end
