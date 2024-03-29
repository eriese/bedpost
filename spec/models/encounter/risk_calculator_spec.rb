require 'rails_helper'

RSpec.describe Encounter::RiskCalculator, type: :model do
	before :each do
		allow(Diagnosis).to receive(:as_map) { Hash.new { |hsh, key| hsh[key] = build_stubbed(:diagnosis, { name: key }) } }
		allow(PossibleContact).to receive(:as_map) {
																													Hash.new { |hsh, key|
																														hsh[key] =
																															build_stubbed(:possible_contact,
																																													{ subject_instrument_id: :external_genitals,
																																															object_instrument_id: :internal_genitals, _id: key })
																													}
																												}
		allow(Contact::Instrument).to receive(:as_map) {
																																	Hash.new { |hsh, key|
																																		hsh[key] = build_stubbed(:contact_instrument, { name: key })
																																	}
																																}
		allow(Diagnosis::TransmissionRisk).to receive(:grouped_by) {
																																									Hash.new { |hsh, key|
																																										hsh[key] =
																																											[build_stubbed(:diagnosis_transmission_risk, { possible_contact_id: key })]
																																									}
																																								}
	end

	def stub_encounter
		ship = build_stubbed(:partnership, partner: build_stubbed(:profile))
		@user = build_stubbed(
			:user_profile,
			encounters: [build(:encounter, partnership_id: ship.id)],
			partnerships: [ship]
		)
		@user.encounters.first
	end

	it 'creates a map showing the highest transmission risk of the encounter for each diagnosis' do
		encounter = stub_encounter

		calc = Encounter::RiskCalculator.new(encounter)
		risks = calc.instance_variable_get(:@risks)

		contact1 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact1' })
		calc.track_contact(contact1)
		risk1 = risks[contact1.possible_contact_id][0]

		expect(calc.risk_map[risk1.diagnosis_id]).to eq risk1.risk_to_subject

		contact2 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact2' })
		calc.track_contact(contact2)
		risk2 = risks[contact2.possible_contact_id][0]

		contact3 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact3' })
		calc.track_contact(contact3)
		risk3 = risks[contact3.possible_contact_id][0]

		expected = [risk1.risk_to_subject, risk2.risk_to_subject, risk3.risk_to_subject].max
		expect(calc.risk_map[risk1.diagnosis_id]).to eq expected
	end

	describe '#track_contact' do
		describe 'with an effective barrier' do
			it 'returns negligible risk' do
				contact1 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact1', barriers: ['fresh'] })
				encounter = stub_encounter
				encounter.contacts = [contact1]
				calc = Encounter::RiskCalculator.new(encounter)

				calc.instance_variable_get(:@risks)['contact1'][0].risk_to_subject = Diagnosis::TransmissionRisk::HIGH

				calc.track_contact(contact1)

				expect(contact1.risks[:hpv][0]).to eq Diagnosis::TransmissionRisk::NEGLIGIBLE
			end
		end
	end

	describe '#track' do
		before :each do
			@contact1 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact1' })
			@contact2 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact2' })
			@contact3 = build_stubbed(:encounter_contact, { possible_contact_id: 'contact3', barriers: ['fresh'] })

			@encounter = stub_encounter
			@encounter.contacts = [@contact1, @contact2, @contact3]
			@calc = Encounter::RiskCalculator.new(@encounter)
			@calc.instance_variable_get(:@diagnoses)[:hpv]
		end

		it 'tracks all contacts in an encounter' do
			allow(@encounter.partnership).to receive(:risk_mitigator) { 0 }
			@calc.track

			risks = @calc.instance_variable_get(:@risks)

			risk1 = risks[@contact1.possible_contact_id][0]
			risk2 = risks[@contact2.possible_contact_id][0]
			risk3 = risks[@contact3.possible_contact_id][0]

			expected = [risk1.risk_to_subject, risk2.risk_to_subject].max
			expect(@calc.risk_map[risk1.diagnosis_id]).to eq expected
			expect(@contact3.risks[:hpv][0]).to eq Diagnosis::TransmissionRisk::NEGLIGIBLE
		end

		context 'risk mitigation' do
			context 'when calculating risk-to-user' do
				it 'mitigates risks by the partnership risk mitgator' do
					mitigation = 1
					allow(@encounter.partnership).to receive(:risk_mitigator) { mitigation }
					risks = @calc.instance_variable_get(:@risks)
					risk1 = risks[@contact1.possible_contact_id][0]
					risk1.risk_to_subject = 3

					@calc.track
					expect(@contact1.risks[risk1.diagnosis_id][0]).to eq(risk1.risk_to_subject - mitigation)
				end

				it 'does not mitigate below negligible' do
					mitigation = 1
					allow(@encounter.partnership).to receive(:risk_mitigator) { mitigation }
					risks = @calc.instance_variable_get(:@risks)
					risk1 = risks[@contact1.possible_contact_id][0]
					risk1.risk_to_subject = Diagnosis::TransmissionRisk::NEGLIGIBLE

					@calc.track
					expect(@contact1.risks[risk1.diagnosis_id][0]).to eq(Diagnosis::TransmissionRisk::NEGLIGIBLE)
				end
			end

			context 'when calculating risk-to-partner' do
				it 'mitigates risk by the user risk mitgator' do
					mitigation = 1
					allow(@user).to receive(:risk_mitigator) { mitigation }
					risks = @calc.instance_variable_get(:@risks)
					risk1 = risks[@contact1.possible_contact_id][0]
					risk1.risk_to_object = 3

					@calc.track(:partner)
					expect(@contact1.risks[risk1.diagnosis_id][0]).to eq(risk1.risk_to_object - mitigation)
				end
			end

			it 'does not mitigate below no risk' do
				mitigation = 2
				allow(@user).to receive(:risk_mitigator) { mitigation }
				risks = @calc.instance_variable_get(:@risks)
				risk1 = risks[@contact1.possible_contact_id][0]
				risk1.risk_to_object = Diagnosis::TransmissionRisk::NO_RISK + 1

				@calc.track(:partner)
				expect(@contact1.risks[risk1.diagnosis_id][0]).to eq(Diagnosis::TransmissionRisk::NO_RISK)
			end
		end
	end

	describe '#schedule' do
		before :each do
			@encounter = stub_encounter
		end

		it 'returns a hash with best test dates as keys and arrays of diagnoses as values' do
			calc = Encounter::RiskCalculator.new(@encounter)
			calc.instance_variable_set :@risk_map, {
				hpv: Diagnosis::TransmissionRisk::MODERATE,
				hsv: Diagnosis::TransmissionRisk::HIGH
			}

			result = calc.schedule
			diags = calc.instance_variable_get(:@diagnoses)
			expected_hpv_best = diags[:hpv].best_test
			expected_hiv_best = diags[:hpv].best_test

			expect(expected_hiv_best).to eq expected_hpv_best
			expected_date = @encounter.took_place + expected_hpv_best.weeks
			expect(result).to have_key expected_date
			expect(result[expected_date].length).to be 2
			expect(result[expected_date]).to include(:hpv)
			expect(result[expected_date]).to include(:hsv)
		end

		it 'keys LOW and NEGLIGIBLE risk diagnoses with :routine' do
			calc = Encounter::RiskCalculator.new(@encounter)
			calc.instance_variable_set :@risk_map, {
				hpv: Diagnosis::TransmissionRisk::NEGLIGIBLE,
				hsv: Diagnosis::TransmissionRisk::LOW,
				hiv: Diagnosis::TransmissionRisk::MODERATE
			}

			result = calc.schedule
			diags = calc.instance_variable_get(:@diagnoses)
			best_hiv = @encounter.took_place + diags[:hiv].best_test.weeks

			expect(result[best_hiv]).to eq [:hiv]
			expect(result[:routine]).to include(:hpv)
			expect(result[:routine]).to include(:hsv)
		end

		it 'keys LOW and NEGLIGIBLE risk diagnoses with their best dates if passed force = true' do
			calc = Encounter::RiskCalculator.new(@encounter)
			calc.instance_variable_set :@risk_map, {
				hpv: Diagnosis::TransmissionRisk::NEGLIGIBLE,
				hsv: Diagnosis::TransmissionRisk::LOW,
				hiv: Diagnosis::TransmissionRisk::MODERATE
			}
			result = calc.schedule(true)
			diags = calc.instance_variable_get(:@diagnoses)
			best_hiv = @encounter.took_place + diags[:hiv].best_test.weeks
			best_hsv = @encounter.took_place + diags[:hsv].best_test.weeks
			best_hpv = @encounter.took_place + diags[:hpv].best_test.weeks

			expect(result).to_not have_key :routine
			expect(result[best_hiv]).to include(:hiv)
			expect(result[best_hpv]).to include(:hpv)
			expect(result[best_hsv]).to include(:hsv)
		end
	end

	describe '#contact_keys' do
		it 'uses the alias name rather than the name of the instruments as the second key' do
			calc = Encounter::RiskCalculator.new(stub_encounter)
			instruments = calc.instance_variable_get(:@instruments)
			instruments[:fingers].alias_of_id = :hand

			cur_possible = build_stubbed(:possible_contact,
																																{ subject_instrument_id: :fingers, object_instrument_id: :internal_genitals,
																																		_id: 'pos1' })
			cur_contact = build_stubbed(:encounter_contact, possible_contact_id: 'pos1')
			calc.instance_variable_set(:@cur_possible, cur_possible)
			calc.instance_variable_set(:@cur_contact, cur_contact)

			result = calc.contact_keys

			expect(result[0][1]).to eq :hand
			expect(result[1][1]).to eq :internal_genitals
		end
	end
end
