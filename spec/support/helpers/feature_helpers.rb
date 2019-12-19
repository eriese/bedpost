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
		click_button 'Submit'
	end

	def register_user
		visit new_user_profile_registration_path
		@user_params = attributes_for(:user_profile)
		fill_in 'First name*', with: @user_params[:name]
		fill_in 'Email*', with: @user_params[:email]
		fill_in 'Password*', with: @user_params[:password]
		fill_in 'Re-type your password*', with: @user_params[:password]
		click_button "signup-submit"
	end

	def fill_in_profile(user_params = nil, is_user: true)
		user_params ||= @user_params
		model = is_user ? 'user_profile' : 'partnership_partner_attributes'
		fill_in "#{model}_name", with: user_params[:name] unless is_user
		select(Pronoun.find(user_params[:pronoun_id]).display, from: "#{model}_pronoun_id")
		fill_in "#{model}_anus_name", with: user_params[:anus_name]
		fill_in "#{model}_external_name", with: user_params[:external_name]
		choose("#{model}_can_penetrate_#{user_params[:can_penetrate]}")
		fill_in "#{model}_internal_name", with: user_params[:internal_name]
		click_button 'Save' if is_user
	end

	def fill_in_partnership(and_profile=true)
		fill_in "partnership_nickname", with: "nickname"
		# fill in form and submit
		fields = Partnership::LEVEL_FIELDS
		lvls = Array.new(fields.length) {rand(1..10).to_s}
		indexes = (0...fields.length)
		indexes.each do |i|
			fill_in "partnership_#{fields[i]}", with: lvls[i]
		end
		fill_in_profile(attributes_for(:profile), is_user: false) if and_profile
		find('input[name="commit"]').click
	end

	def accept_terms
		find_by_id('terms_acceptance_true').set(true)
		find('input[name="commit"]').click
	end
end
