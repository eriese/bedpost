require "rails_helper"

RSpec.describe RegistrationMailer, type: :mailer do
	before :all do
		described_class.delivery_method = :test
	end

	describe 'removal' do
		user_id = 'random'
		email = 'email@email.com'
		name = 'Emily'

		it 'sends to the given email address' do
			mail = described_class.removal(user_id, email, name, true)
			expect(mail.to).to eq [email]
		end

		context 'with a soft delete' do
			let (:mail) {described_class.removal(user_id, email, name, true).deliver_now}

			it 'has the correct subject' do
				expect(mail.subject).to eq 'You successfully deleted your account with bedpost'
			end

			it 'puts the former user_id in the email so the user can ask to be hard deleted' do
				expect(mail.body.encoded).to match(user_id)
			end
		end

		context 'with a hard delete' do
			let (:mail) {described_class.removal(user_id, email, name, false).deliver_now}

			it 'has the correct subject' do
				expect(mail.subject).to eq 'You successfully deleted your account with bedpost'
			end

			it 'does not put the former user_id in the emaiil body' do
				expect(mail.body.encoded).not_to match(user_id)
			end
		end
	end
end
