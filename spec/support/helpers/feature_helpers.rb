module FeatureHelpers

	def t_text(key, **options)
		strip_tags(I18n.t(key, options)).strip
	end

	def login_new_user
		user_params = attributes_for(:user_profile)
		@user = create(:user_profile, user_params);

		visit new_user_profile_session_path
		fill_in 'Email*', with: @user.email
		fill_in 'Password*', with: user_params[:password]
		click_button "Log in"
	end
end
