require 'rails_helper'

RSpec.describe Diagnosis::TransmissionRisk, type: :model do
	describe '#risk_to_person' do
		context 'if the person is the subject' do
			it 'returns the risk to the subject' do
				risk = build(:diagnosis_transmission_risk, risk_to_subject: 3)
				contact = build(:encounter_contact, subject: :user, object: :partner)

				expect(risk.risk_to_person(contact, false)).to eq 3
			end
		end

		context 'if the person is both subject and object' do
			it 'returns the risk to self' do
				risk = build(:diagnosis_transmission_risk, risk_to_subject: 1, risk_to_object: 3, risk_to_self: 2)
				contact = build(:encounter_contact, subject: :user, object: :user)

				expect(risk.risk_to_person(contact, false)).to eq 2
			end
		end

		context 'if the person is the object' do
			it 'returns the risk to the object' do
				risk = build(:diagnosis_transmission_risk, risk_to_object: Diagnosis::TransmissionRisk::MODERATE)
				contact = build(:encounter_contact, subject: :user, object: :partner)

				expect(risk.risk_to_person(contact, false, :partner)).to eq risk.risk_to_object
			end
		end

		context 'bump_risk' do
			it 'bumps the risk 1 point' do
				risk = build(:diagnosis_transmission_risk, risk_to_subject: Diagnosis::TransmissionRisk::LOW)
				contact = build(:encounter_contact, subject: :user, object: :partner)

				expect(risk.risk_to_person(contact, true)).to eq risk.risk_to_subject + 1
			end

			it 'does not bump the risk higher than HIGH' do
				risk = build(:diagnosis_transmission_risk, risk_to_subject: Diagnosis::TransmissionRisk::HIGH)
				contact = build(:encounter_contact, subject: :user, object: :partner)

				expect(risk.risk_to_person(contact, true)).to eq Diagnosis::TransmissionRisk::HIGH
			end
		end
	end
end
