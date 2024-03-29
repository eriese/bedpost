FactoryBot.define do
	factory :diagnosis_transmission_risk, class: 'Diagnosis::TransmissionRisk' do
		risk_to_subject { rand(Diagnosis::TransmissionRisk::LOW..Diagnosis::TransmissionRisk::MODERATE) }
		risk_to_object { rand(Diagnosis::TransmissionRisk::LOW..Diagnosis::TransmissionRisk::MODERATE) }
		risk_to_self { rand(Diagnosis::TransmissionRisk::LOW..Diagnosis::TransmissionRisk::MODERATE) }
		diagnosis_id { :hpv }
		barriers_effective { true }
	end
end
