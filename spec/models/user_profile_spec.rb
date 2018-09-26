require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  before(:all) do
	@user1 = create(:user_profile)
  end

  after(:all) do
  	@user1.destroy
  end

  it "doesn't allow duplicate uids" do
  	user2 = build(:user_profile)
  	expect(user2).to_not be_valid
  	expect(user2).to have_validation_error_for(:uid, :taken)
  end

  it "requires an email" do
  	user2 = build(:user_profile, email: nil, uid: "2345")
  	expect(user2).to_not be_valid
  	expect(user2).to have_validation_error_for(:email, :blank)
  end

  it "doesn't allow duplicate emails" do
  	user2 = build(:user_profile, email: @user1.email, uid: "2345")
  	expect(user2).to_not be_valid
  	expect(user2).to have_validation_error_for(:email, :taken)
  end

  it "generates a password hash" do
  	pass = BCrypt::Password.new(@user1.password_digest)
  	original = attributes_for(:user_profile)[:password]
  	expect(pass).to eq original
  end

  it "only requires a pronoun on update" do
  	user2 = build(:user_profile, pronoun: nil, uid: "2345")
  	expect(user2).to be_valid

  	user3 = build_stubbed(:user_profile, pronoun: nil)
  	expect(user3).to_not be_valid
    expect(user3).to have_validation_error_for(:pronoun, :blank)
  end

  it "only requires a name for the anus on update" do
  	user2 = build(:user_profile, anus_name: nil, uid: "2345")
  	expect(user2).to be_valid

  	user3 = build_stubbed(:user_profile, anus_name: nil)
  	expect(user3).to_not be_valid
    expect(user3).to have_validation_error_for(:anus_name, :blank)
  end

  it "only requires a name for the external genitals on update" do
  	user2 = build(:user_profile, external_name: nil, uid: "2345")
  	expect(user2).to be_valid

  	user3 = build_stubbed(:user_profile, external_name: nil)
  	expect(user3).to_not be_valid
    expect(user3).to have_validation_error_for(:external_name, :blank)
  end

end
