require 'rails_helper'

RSpec.describe RemoveOrphanedProfileJob, type: :job do
	context 'with a profile that is not in the database' do
		it 'does not raise a DocumentNotFound error' do
			expect {described_class.perform_now("random")}.not_to raise_error
		end
	end

	context 'with a profile that still has partnerships' do
		after do
			cleanup @user, @profile
		end

		it 'does not delete the profile' do
			@user = create(:user_profile)
			@profile = create(:profile)

			@user.partnerships << build(:partnership, partner_id: @profile.id)
			@user.save

			described_class.perform_now(@profile.id.to_s)
			expect(@profile.reload).to be_persisted
		end
	end

	context 'with a profile that has no partnerships' do
		after do
			cleanup @profile
		end

		it 'deletes the profile' do
			@profile = create(:profile)
			described_class.perform_now(@profile.id.to_s)
			expect { @profile.reload }.to raise_error Mongoid::Errors::DocumentNotFound
		end
	end

	context 'with a UserProfile' do
		after do
			cleanup @user
		end

		it 'does not delete the profile even if it has no partnerships' do
			@user = create(:user_profile)
			described_class.perform_now(@user.id.to_s)
			expect(@user.reload).to be_persisted
		end
	end
end
