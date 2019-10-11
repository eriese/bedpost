require 'rails_helper'

RSpec.describe UserProfile, type: :model do

  it_should_behave_like 'an object that dirty-tracks its embedded relations', UserProfile, :user_profile

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

    describe '#password' do
      it "generates a password hash" do
        pass = BCrypt::Password.new(dummy_user.encrypted_password)
        original = attributes_for(:user_profile)[:password]
        expect(pass).to eq original
      end
    end
  end

  context 'methods' do
    describe '#encounters' do
      before :each do
        @user = create(:user_profile)
      end

      after :each do
        cleanup(@user)
      end

      it 'gets an array of all encounters embedded in the partnerships of the user' do
        ship = @user.partnerships.create(partner: dummy_user)
        encounter = ship.encounters.create

        result = @user.encounters
        expect(result).to include encounter
        expect(result.size).to eq 1
      end
    end

    describe '#as_json' do
      it 'does not include the passsword or encrypted_password' do
        user = build_stubbed(:user_profile)
        result = user.as_json

        expect(result).to_not include("encrypted_password")
        expect(result).to_not include("password")
      end
    end

    describe '#update_without_password' do
      before :each do
        @user = create(:user_profile)
      end

      after :each do
        cleanup(@user)
      end

      it 'never updates the password' do
        oldPass = @user.encrypted_password
        params = {name: "new name", password: "new password", password_confirmation: "new password"}
        @user.update_without_password(params)
        @user.reload
        expect(@user.name).to eq params[:name]
        expect(@user.encrypted_password).to eq oldPass
      end

      it 'never updates the email' do
        oldEmail = @user.email
        params = {name: "new name", email: "newEmail@mail.com"}
        @user.update_without_password(params)
        @user.reload
        expect(@user.name).to eq params[:name]
        expect(@user.email).to eq oldEmail
      end
    end

    describe '#soft_destroy' do
      before :each do
        @user = create(:user_profile)
      end

      after :each do
        cleanup(@user)
      end

      context 'with a user with #opt_in = true' do
        before :each do
          @user.update({opt_in: true})
        end

        it 'clears the email address' do
          expect(@user.soft_destroy).to be true
          @user.reload
          expect(@user.email).to be_nil
        end

        it 'sets a deleted_at timestamp' do
          @user.soft_destroy
          @user.reload
          expect(@user.deleted_at).to_not be_nil
        end
      end

      context 'with a user with #opt_in = false' do
        before :each do
          cleanup(@user)
          @user = create(:user_profile)
        end

        after :each do
          cleanup(@user, @partner, @dummy)
        end

        it 'calls destroy on the user' do
          allow(@user).to receive(:destroy).and_call_original
          @user.soft_destroy
          expect(@user).to have_received(:destroy)
        end

        it 'creates a placeholder user with the same preferences as the user if the user is partnered to any other user profiles' do
          @partner = create(:user_profile)
          @partner.partnerships << build(:partnership, partner_id: @user.id)
          @user.reload

          expect(@user.partnered_to_ids).to_not be_empty

          @user.soft_destroy
          @dummy = Profile.last unless Profile.last.id == @partner.id
          expect(@dummy.name).to eq @user.name
          expect(@dummy.partnered_to_ids).to eq @user.partnered_to_ids
        end
      end
    end
  end

  context 'nested' do
    context 'partnerships' do
      after :each do
        cleanup(@user, @partner)
      end

      it 'destroys dummy partners when it is destroyed' do
        @user = create(:user_profile)
        @partner = create(:profile)

        @user.partnerships.create(partner: @partner)

        expect{@user.destroy}.to change(Profile, :count).by(-2)
        expect(@user.persisted?).to be false
        expect(Profile.where(id: @partner.id).count).to eq 0
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
