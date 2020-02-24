require 'rails_helper'

RSpec.describe "tours/index", type: :view do
	describe 'first visit' do
		before :each do
			@num_partnerships = assign(:num_partnerships, 0)
			@has_partnerships = assign(:has_partnerships, false)
			@first_partner = assign(:first_partner, nil)
			@user = build_stubbed(:user_profile)
			allow(view).to receive(:current_user_profile).and_return(@user)
			render
		end

		it 'has a title with the name of the user in it' do
			assert_select('h1', {text: /#{@user.name}/})
			assert_select('h1', {text: I18n.t("tours.index.header", {name: @user.name})})
		end

		it 'has a description' do
			assert_select('h2', {text: I18n.t("tours.index.desc")})
		end

		it 'has a link to the new partnership path' do
			assert_select("a[href='#{new_partnership_path}']", {text: I18n.t("tours.index.add_partnership.zero")})
		end

		it 'does not have a link to the new encounter path' do
			assert_select("a[href='#{encounters_who_path}']", false)
		end

		it 'has an exit button' do
			assert_select("form[method='post'][action='#{first_time_path}']")
		end
	end

	describe 'second visit, with one partner' do
		before :each do
			@num_partnerships = assign(:num_partnerships, 1)
			@has_partnerships = assign(:has_partnerships, true)
			@first_partner = assign(:first_partner, build_stubbed(:partnership, partner: build_stubbed(:profile)))
			@user = build_stubbed(:user_profile)
			allow(view).to receive(:current_user_profile).and_return(@user)
			render
		end

		it 'has a title with the name of the user in it' do
			assert_select('h1', {text: /#{@user.name}/})
			assert_select('h1', {text: I18n.t("tours.index.header2", {name: @user.name})})
		end

		it 'has a description that indicates the user has one partnership' do
			partner_name = @first_partner.partner.name
			assert_select('p', {text: /#{partner_name}/})
			assert_select('p', {text: I18n.t("tours.index.desc2.one", {partner_name: partner_name})})
		end

		it 'has a link to the new partnership path' do
			assert_select("a[href='#{new_partnership_path}']", {text: I18n.t("tours.index.add_partnership.other")})
		end

		it 'has a link to the new encounter path with the partner' do
			assert_select("a[href='#{new_encounter_path}']", {text: I18n.t("tours.index.add_encounter")})
		end

		it 'has an exit button' do
			assert_select("form[method='post'][action='#{first_time_path}']")
		end
	end

	describe 'subsequent visits with more than one partner' do
		before :each do
			@num_partnerships = assign(:num_partnerships, 2)
			@has_partnerships = assign(:has_partnerships, true)
			@user = build_stubbed(:user_profile)
			allow(view).to receive(:current_user_profile).and_return(@user)
			render
		end

		it 'has a title with the name of the user in it' do
			assert_select('h1', {text: /#{@user.name}/})
			assert_select('h1', {text: I18n.t("tours.index.header2", {name: @user.name})})
		end

		it 'has a description that indicates that the user has multiple partnerships' do
			assert_select('p', {text: I18n.t("tours.index.desc2.other")})
		end

		it 'has a link to the new partnership path' do
			assert_select("a[href='#{new_partnership_path}']", {text: I18n.t("tours.index.add_partnership.other")})
		end

		it 'has a link to the new encounter path with the partner' do
			assert_select("a[href='#{new_encounter_path}']", {text: I18n.t("tours.index.add_encounter")})
		end

		it 'has an exit button' do
			assert_select("form[method='post'][action='#{first_time_path}']")
		end
	end
end
