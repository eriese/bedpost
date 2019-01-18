require 'rails_helper'

RSpec.describe UserProfile, type: :model do

  it_should_behave_like 'an object that dirty-tracks its embedded relations', UserProfile.new

  context 'fields' do
    describe "#uid" do
      it "generates a uid on initialization" do
        user1 = build(:user_profile)
        expect(user1.uid).to_not be nil
      end

      it "doesn't allow duplicate uids" do
      	user1 = build(:user_profile, uid: dummy_user.uid)
      	expect(user1).to_not be_valid
      	expect(user1).to have_validation_error_for(:uid, :taken)
      end
    end

    describe "#email" do
      it "requires an email" do
      	user1 = build(:user_profile, email: nil)
      	expect(user1).to_not be_valid
      	expect(user1).to have_validation_error_for(:email, :blank)
      end

      it "lowercases emails on initialization" do
        email = "UPPERCASE@example.com"
        user1 = build(:user_profile, email: email)
        expect(user1.email).to eq email.downcase
      end

      it "doesn't allow duplicate emails" do
      	user1 = build(:user_profile, email: dummy_user.email)
      	expect(user1).to_not be_valid
      	expect(user1).to have_validation_error_for(:email, :taken)
      end
    end

    it "generates a password hash" do
      pass = BCrypt::Password.new(dummy_user.password_digest)
      original = attributes_for(:user_profile)[:password]
      expect(pass).to eq original
    end
  end

  context 'methods' do
    describe '#password_valid?' do
      it 'runs validations on the password' do
        user1 = build_stubbed(:user_profile)
        valid = user1.send(:password_valid?)
        expect(valid).to be true
      end

      it 'rejects invalid passwords' do
        pass = "p" * 73
        user1 = build_stubbed(:user_profile, password: pass)
        valid = user1.send(:password_valid?)
        expect(valid).to be false
      end
    end

    describe '#update_only_password' do
      before :each do
        @user = create(:user_profile)
      end

      after :each do
        @user.destroy
      end

      it 'does not update if the password is invalid' do
        pass = "p" * 6
        expect(@user.update_only_password(pass)).to be false
      end

      it 'updates the password digest on the user' do
        pass = "new-pass"
        result = @user.update_only_password(pass)
        expect(result).to be true
        expect(@user.authenticate(pass)).to be @user
      end

      it 'does not retain the old password' do
        pass = "new-pass"
        old = attributes_for(:user_profile)[:password]
        result = @user.update_only_password(pass)
        expect(result).to be true
        expect(@user.authenticate(old)).to be false
      end

      it 'works even if the rest of the user is not valid' do
        @user.pronoun = nil
        expect(@user).to_not be_valid
        pass = "new-pass"

        expect(@user.update_only_password(pass)).to be true
      end

      it 'is persisted in the database' do
        pass = "new-pass"
        @user.update_only_password(pass)

        persisted = UserProfile.find(@user.id)
        expect(persisted).to eq @user
        expect(persisted.authenticate(pass)).to eq persisted
      end
    end
  end


  context 'validations' do
    it "only requires a pronoun on update" do
    	user1 = build(:user_profile, pronoun: nil)
    	expect(user1).to be_valid

    	user2 = build_stubbed(:user_profile, pronoun: nil)
    	expect(user2).to_not be_valid
      expect(user2).to have_validation_error_for(:pronoun, :blank)
    end

    it "only requires a name for the anus on update" do
    	user1 = build(:user_profile, anus_name: nil)
    	expect(user1).to be_valid

    	user2 = build_stubbed(:user_profile, anus_name: nil)
    	expect(user2).to_not be_valid
      expect(user2).to have_validation_error_for(:anus_name, :blank)
    end

    it "only requires a name for the external genitals on update" do
    	user1 = build(:user_profile, external_name: nil)
    	expect(user1).to be_valid

    	user2 = build_stubbed(:user_profile, external_name: nil)
    	expect(user2).to_not be_valid
      expect(user2).to have_validation_error_for(:external_name, :blank)
    end
  end

end
