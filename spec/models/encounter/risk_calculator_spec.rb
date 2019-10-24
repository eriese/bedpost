require 'rails_helper'

RSpec.describe Encounter::RiskCalculator, type: :model do
  before :each do
  	allow(Diagnosis).to receive(:as_map) {Hash.new {|hsh, key| hsh[key] = build_stubbed(:diagnosis, {name: key})}}
  	allow(PossibleContact).to receive(:as_map) {Hash.new { |hsh, key| hsh[key] = build_stubbed(:possible_contact, {subject_instrument_id: :external_genitals, object_instrument_id: :internal_genitals, _id: key}) }}
  	allow(Contact::Instrument).to receive(:as_map) {Hash.new { |hsh, key| hsh[key] = build_stubbed(:contact_instrument, {name: key}) }}
  	allow(Diagnosis::TransmissionRisk).to receive(:grouped_by) {Hash.new { |hsh, key| hsh[key] = [build_stubbed(:diagnosis_transmission_risk, {possible_contact_id: key})] }}
  end

  it 'creates a map showing the highest transmission risk of the encounter for each diagnosis' do
  	calc = Encounter::RiskCalculator.new(Encounter.new)
  	risks = calc.instance_variable_get(:@risks)

  	contact1 = build_stubbed(:encounter_contact, {possible_contact_id: "contact1"})
  	calc.track_contact(contact1)
  	risk1 = risks[contact1.possible_contact_id][0]

  	expect(calc.risk_map[risk1.diagnosis_id]).to eq risk1.risk_to_subject

  	contact2 = build_stubbed(:encounter_contact, {possible_contact_id: "contact2"})
  	calc.track_contact(contact2)
  	risk2 = risks[contact2.possible_contact_id][0]

  	contact3 = build_stubbed(:encounter_contact, {possible_contact_id: "contact3"})
  	calc.track_contact(contact3)
  	risk3 = risks[contact3.possible_contact_id][0]

  	expected = [risk1.risk_to_subject, risk2.risk_to_subject, risk3.risk_to_subject].max
  	expect(calc.risk_map[risk1.diagnosis_id]).to eq expected
  end

  describe '#track_contact' do
    describe 'with an effective barrier' do
      it 'returns negligible risk' do
        contact1 = build_stubbed(:encounter_contact, {possible_contact_id: "contact1", barriers: ["fresh"]})
        encounter = build(:encounter)
        encounter.contacts = [contact1]
        calc = Encounter::RiskCalculator.new(encounter)

        calc.instance_variable_get(:@risks)["contact1"][0].risk_to_subject = Diagnosis::TransmissionRisk::HIGH

        calc.track_contact(contact1)

        expect(contact1.risks[:hpv]).to eq Diagnosis::TransmissionRisk::NEGLIGIBLE
      end
    end
  end

  describe '#track' do
    before :each do
      @contact1 = build_stubbed(:encounter_contact, {possible_contact_id: "contact1"})
      @contact2 = build_stubbed(:encounter_contact, {possible_contact_id: "contact2"})
      @contact3 = build_stubbed(:encounter_contact, {possible_contact_id: "contact3", barriers: ["fresh"]})

      @ship = build_stubbed(:partnership)
      @encounter = build_stubbed(:encounter)
      @ship.encounters = [@encounter]
      @encounter.contacts = [@contact1, @contact2, @contact3]
      @calc = Encounter::RiskCalculator.new(@encounter)
      @calc.instance_variable_get(:@diagnoses)[:hpv]
    end

    it 'tracks all contacts in an encounter' do
      allow(@ship).to receive(:risk_mitigator) {0}
      @calc.track

      risks = @calc.instance_variable_get(:@risks)

      risk1 = risks[@contact1.possible_contact_id][0]
      risk2 = risks[@contact2.possible_contact_id][0]
      risk3 = risks[@contact3.possible_contact_id][0]

      expected = [risk1.risk_to_subject, risk2.risk_to_subject].max
      expect(@calc.risk_map[risk1.diagnosis_id]).to eq expected
      expect(@contact3.risks[:hpv]).to eq Diagnosis::TransmissionRisk::NEGLIGIBLE
    end

    context 'risk mitigation' do
      context 'when calculating risk-to-user' do
        it 'mitigates risks by the partnership risk mitgator' do
          mitigation = 1
          allow(@encounter.partnership).to receive(:risk_mitigator) {mitigation}
          risks = @calc.instance_variable_get(:@risks)
          risk1 = risks[@contact1.possible_contact_id][0]
          risk1.risk_to_subject = 3

          @calc.track
          expect(@contact1.risks[risk1.diagnosis_id]).to eq(risk1.risk_to_subject - mitigation)
        end

        it 'does not mitigate below negligible' do
          mitigation = 1
          allow(@encounter.partnership).to receive(:risk_mitigator) {mitigation}
          risks = @calc.instance_variable_get(:@risks)
          risk1 = risks[@contact1.possible_contact_id][0]
          risk1.risk_to_subject = Diagnosis::TransmissionRisk::NEGLIGIBLE

          @calc.track
          expect(@contact1.risks[risk1.diagnosis_id]).to eq(Diagnosis::TransmissionRisk::NEGLIGIBLE)
        end
      end

      context 'when calculating risk-to-partner' do
        it 'mitigates risk by the user risk mitgator' do
          mitigation = 1
          allow(@encounter.partnership).to receive(:user_profile) {double("UserProfile", risk_mitigator: mitigation)}
          risks = @calc.instance_variable_get(:@risks)
          risk1 = risks[@contact1.possible_contact_id][0]
          risk1.risk_to_object = 3

          @calc.track(:partner)
          expect(@contact1.risks[risk1.diagnosis_id]).to eq(risk1.risk_to_object - mitigation)
        end
      end

        it 'does not mitigate below no risk' do
          mitigation = 2
          allow(@encounter.partnership).to receive(:user_profile) {double("UserProfile", risk_mitigator: mitigation)}
          risks = @calc.instance_variable_get(:@risks)
          risk1 = risks[@contact1.possible_contact_id][0]
          risk1.risk_to_object = Diagnosis::TransmissionRisk::NO_RISK + 1

          @calc.track(:partner)
          expect(@contact1.risks[risk1.diagnosis_id]).to eq(Diagnosis::TransmissionRisk::NO_RISK)
        end
    end
  end
end
